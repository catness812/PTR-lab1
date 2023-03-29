defmodule UserEngagementRatioComp do
  use GenServer

  def start do
    IO.puts("-> User Engagement Ratio Calculator started\n")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    state = []
    {:ok, state}
  end

  def handle_info(%HTTPoison.AsyncStatus{}, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncHeaders{}, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    if String.length(chunk) > 0 do
      "event: \"message\"\n\ndata: " <> response = chunk
      {status, user} = Jason.decode(String.trim(response))
      case status do
        :ok -> user_name = user
                |> Map.get("message")
                |> Map.get("tweet")
                |> Map.get("user")
                |> Map.get("screen_name")
                favourites_count = user
                |> Map.get("message")
                |> Map.get("tweet")
                |> Map.get("user")
                |> Map.get("favourites_count")
                statuses_count = user
                |> Map.get("message")
                |> Map.get("tweet")
                |> Map.get("user")
                |> Map.get("statuses_count")
                followers_count = user
                |> Map.get("message")
                |> Map.get("tweet")
                |> Map.get("user")
                |> Map.get("followers_count")
                unless Enum.member?(state, user_name) do
                  state = Enum.concat(state, [user_name])
                  if followers_count != 0 do
                    user_engagement_ratio = (favourites_count + statuses_count) / followers_count
                    IO.puts("User @#{user_name} has an engagement ratio of: #{user_engagement_ratio}\n")
                  else
                    IO.puts("User @#{user_name} has an engagement ratio of: 0\n")
                  end
                end
                {:noreply, state}
        _ -> {:noreply, state}
      end
    else
      {:noreply, state}
    end
  end

  def handle_info(%HTTPoison.AsyncEnd{}, state) do
    {:noreply, state}
  end
end
