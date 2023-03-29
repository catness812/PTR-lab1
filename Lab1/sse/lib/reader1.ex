defmodule Reader1 do
  use GenServer

  def start(nr_of_pools) do
    IO.puts("\n-> Reader 1 started")
    GenServer.start_link(__MODULE__, [nr_of_pools], name: __MODULE__)
  end

  def init(nr_of_pools) do
    {:ok, %{nr_of_pools: nr_of_pools}}
  end

  def handle_cast(:get_tweets, state) do
    HTTPoison.get("http://localhost:4000/tweets/1", [], [recv_timeout: :infinity, stream_to: self()])
    {:noreply, state}
  end

  def handle_cast(:get_hashtags, state) do
    HTTPoison.get("http://localhost:4000/tweets/1", [], [recv_timeout: :infinity, stream_to: HashtagPrinter])
    {:noreply, state}
  end

  def handle_cast(:get_user_info, state) do
    HTTPoison.get("http://localhost:4000/tweets/1", [], [recv_timeout: :infinity, stream_to: UserEngagementRatioComp])
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncStatus{}, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncHeaders{}, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    get_tweets(state.nr_of_pools, chunk)
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncEnd{}, state) do
    {:noreply, state}
  end

  def get_data do
    GenServer.cast(__MODULE__, :get_tweets)
    :getting_data
  end

  def get_tweets(nr_of_pools, chunk) do
    if String.length(chunk) > 0 do
      "event: \"message\"\n\ndata: " <> response = chunk
      {status, tweets} = Jason.decode(String.trim(response))
      case status do
        :ok -> tweet = tweets
                |> Map.get("message")
                |> Map.get("tweet")
                |> Map.get("text")
               favourites = tweets
                |> Map.get("message")
                |> Map.get("tweet")
                |> Map.get("favorite_count")
               retweets = tweets
                |> Map.get("message")
                |> Map.get("tweet")
                |> Map.get("retweet_count")
               followers = tweets
                |> Map.get("message")
                |> Map.get("tweet")
                |> Map.get("user")
                |> Map.get("followers_count")

               event_data = %{
                tweet: tweet,
                favorites: favourites,
                retweets: retweets,
                followers: followers
               }
               StreamProcessorSupervisor.print(nr_of_pools, event_data)
        :error -> StreamProcessorSupervisor.print(nr_of_pools, :kill)
      end
    end
  end

  def send_to_hashtag_printer do
    GenServer.cast(__MODULE__, :get_hashtags)
    :sending_data
  end

  def compute_user_engagement do
    GenServer.cast(__MODULE__, :get_user_info)
  end
end
