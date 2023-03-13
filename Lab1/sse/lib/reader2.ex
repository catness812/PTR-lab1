defmodule Reader2 do
  use GenServer

  def start do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
    IO.puts("-> Reader 2 started with PID: #{inspect pid}\n")
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast(:get_tweets, state) do
    HTTPoison.get("http://localhost:4000/tweets/2", [], [recv_timeout: :infinity, stream_to: self()])
    {:noreply, state}
  end

  def handle_cast(:get_hashtags, state) do
    HTTPoison.get("http://localhost:4000/tweets/2", [], [recv_timeout: :infinity, stream_to: HashtagPrinter])
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncStatus{}, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncHeaders{}, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    get_tweets(chunk)
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncEnd{}, state) do
    {:noreply, state}
  end

  def get_data do
    GenServer.cast(__MODULE__, :get_tweets)
    :getting_data
  end

  def get_tweets(chunk) do
    if String.length(chunk) > 0 do
      "event: \"message\"\n\ndata: " <> response = chunk
      {status, tweets} = Jason.decode(String.trim(response))
      case status do
        :ok -> tweets
                |> Map.get("message")
                |> Map.get("tweet")
                |> Map.get("text")
                |> PrinterSupervisor.print()
        :error -> PrinterSupervisor.print(:kill)
      end
    end
  end

  def send_to_hashtag_printer do
    GenServer.cast(__MODULE__, :get_hashtags)
    :sending_data
  end
end
