defmodule Reader2 do
  use GenServer

  def start(nr_of_pools) do
    IO.puts("\n-> Reader 2 started")
    GenServer.start_link(__MODULE__, nr_of_pools, name: __MODULE__)
  end

  def init(nr_of_pools) do
    state = %{}
    state = Enum.reduce(1..nr_of_pools, state, fn(key, acc) ->
      Map.put(acc, key, 0)
    end)
    {:ok, state}
  end

  def handle_cast(:get_tweets, state) do
    id = Enum.min_by(state, fn {_key, value} -> value end) |> elem(0)
    start_time = Time.utc_now
    StreamProcessorSupervisor.send_time(id, start_time)
    HTTPoison.get("http://localhost:4000/tweets/2", [], [recv_timeout: :infinity, stream_to: self()])
    {:noreply, state}
  end

  def handle_cast(:get_hashtags, state) do
    HTTPoison.get("http://localhost:4000/tweets/2", [], [recv_timeout: :infinity, stream_to: HashtagPrinter])
    {:noreply, state}
  end

  def handle_cast(:get_user_info, state) do
    HTTPoison.get("http://localhost:4000/tweets/2", [], [recv_timeout: :infinity, stream_to: UserEngagementRatioComp])
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncStatus{}, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncHeaders{}, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    id = Enum.min_by(state, fn {_key, value} -> value end) |> elem(0)
    if String.length(chunk) > 0 do
      "event: \"message\"\n\ndata: " <> response = chunk
      {status, tweets} = Jason.decode(String.trim(response))
      case status do
        :ok ->
          if Map.has_key?(tweets["message"]["tweet"], "retweeted_status") do
            user = tweets["message"]["tweet"]["retweeted_status"]["user"]["screen_name"]
            tweet = tweets["message"]["tweet"]["retweeted_status"]["text"]
            favourites = tweets["message"]["tweet"]["retweeted_status"]["favorite_count"]
            retweets = tweets["message"]["tweet"]["retweeted_status"]["retweet_count"]
            followers = tweets["message"]["tweet"]["retweeted_status"]["user"]["followers_count"]
            event_data = %{
              user: user,
              tweet: tweet,
              favorites: favourites,
              retweets: retweets,
              followers: followers
            }
            StreamProcessorSupervisor.print(id, event_data)
          else
            user = tweets["message"]["tweet"]["user"]["screen_name"]
            tweet = tweets["message"]["tweet"]["text"]
            favourites = tweets["message"]["tweet"]["favorite_count"]
            retweets = tweets["message"]["tweet"]["retweet_count"]
            followers = tweets["message"]["tweet"]["user"]["followers_count"]
            event_data = %{
              user: user,
              tweet: tweet,
              favorites: favourites,
              retweets: retweets,
              followers: followers
            }
            StreamProcessorSupervisor.print(id, event_data)
          end
        :error -> StreamProcessorSupervisor.print(id, :kill)
      end
    end
    state = state |> Map.update(id, 0, fn v -> v + 1 end)
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncEnd{}, state) do
    IO.puts("\n-> Stream ended\n")
    {:noreply, state}
  end

  def get_data do
    GenServer.cast(__MODULE__, :get_tweets)
    :getting_data
  end

  def send_to_hashtag_printer do
    GenServer.cast(__MODULE__, :get_hashtags)
    :sending_data
  end

  def compute_user_engagement do
    GenServer.cast(__MODULE__, :get_user_info)
  end
end
