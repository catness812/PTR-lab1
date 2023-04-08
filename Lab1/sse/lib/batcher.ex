defmodule Batcher do
  use GenServer

  def start([batch_size, time_window]) do
    IO.puts("-> Batcher started\n")
    GenServer.start_link(__MODULE__, [batch_size, time_window])
  end

  def init([batch_size, time_window]) do
    state = Map.new(1..batch_size, fn v -> {v, ""} end)
    state = Map.put(state, :time_window, time_window)
    {:ok, state}
  end

  def handle_call({:request_data, batcher_pid}, _from, state) do
    response = Process.alive?(batcher_pid)
    {:reply, response, state}
  end

  def handle_cast({:get_time, start_time}, state) do
    state = Map.put(state, :start_time, start_time)
    {:noreply, state}
  end

  def handle_cast({:collect_data, data}, state) do
    end_time = Time.utc_now
    if Map.has_key?(state, :start_time) and Time.diff(end_time, state[:start_time], :second) > state.time_window do
      state = Map.delete(state, :start_time)
      Enum.each(Map.delete(state, :time_window), fn {_, tweet_data} ->
        unless tweet_data == "" do
          IO.puts("Tweet:\n#{tweet_data[:filtered_tweet]}\nSentiment Score: #{tweet_data[:sentiment_score]}\nEngagement Ratio: #{tweet_data[:engagement_ratio]}\n")
        end
      end)
      state = Enum.reduce(state, %{}, fn {key, _}, acc ->
        Map.put(acc, key, "")
      end)
      start_time = Time.utc_now
      state = Map.put(state, :start_time, start_time)
      {:noreply, state}
    else
      empty_batch = Enum.find_value(state, fn {key, value} ->
        if value == "" do
          {key, value}
        end
      end)
      case empty_batch do
        nil ->
          state = Map.delete(state, :start_time)
          Enum.each(Map.delete(state, :time_window), fn {_, tweet_data} ->
            if tweet_data[:filtered_tweet] == nil or tweet_data[:sentiment_score] == nil or tweet_data[:engagement_ratio] == nil do
              IO.inspect(tweet_data)
            else
              IO.puts("Tweet:\n#{tweet_data[:filtered_tweet]}\nSentiment Score: #{tweet_data[:sentiment_score]}\nEngagement Ratio: #{tweet_data[:engagement_ratio]}\n")
            end
          end)
          state = Enum.reduce(state, %{}, fn {key, _}, acc ->
            Map.put(acc, key, "")
          end)
          start_time = Time.utc_now
          state = Map.put(state, :start_time, start_time)
          {:noreply, state}
        {key, _} ->
          state = Map.update(state, key, "", fn _v -> data end)
          {:noreply, state}
      end
    end
  end

  def get_time(batcher_pid, start_time) do
    GenServer.cast(batcher_pid, {:get_time, start_time})
  end

  def request_data(batcher_pid) do
    GenServer.call(batcher_pid, {:request_data, batcher_pid})
  end

  def collect_data(batcher_pid, data) do
    GenServer.cast(batcher_pid, {:collect_data, data})
  end
end
