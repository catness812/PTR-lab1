defmodule HashtagPrinter do
  use GenServer

  def start do
    IO.puts("\n-> Hashtag Printer started\n")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    state = %{}
    Process.send_after(self(), :schedule_print, 5000)
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
      {status, hashtags} = Jason.decode(String.trim(response))
      case status do
        :ok -> hashtag_list =
                hashtags
                |> Map.get("message")
                |> Map.get("tweet")
                |> Map.get("entities")
                |> Map.get("hashtags")
                |> Enum.map(&(&1["text"] |> String.downcase))
                state = Enum.reduce(hashtag_list, state, fn key, acc ->
                  Map.update(acc, key, 1, &(&1 + 1))
                end)
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

  def handle_info(:schedule_print, state) do
    sorted = Enum.sort_by(state, fn {_hashtag, count} -> -count end)
    sorted = Enum.reject(sorted, &(&1 == nil))
    unless is_nil(Enum.at(sorted, 0)) do
      {hashtag, _count} = Enum.at(sorted, 0)
      IO.puts("\nThe most popular hashtag in the last 5 seconds:\n#" <> hashtag)
    end
    Process.send_after(self(), :schedule_print, 5000)
    {:noreply, state}
  end
end
