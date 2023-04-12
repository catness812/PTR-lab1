defmodule Batcher do
  use GenServer

  alias StreamProcessing.Repo
  alias StreamProcessing.Schemas.{User, Tweet}

  def start([batch_size, time_window]) do
    IO.puts("-> Batcher started\n")
    GenServer.start_link(__MODULE__, [batch_size, time_window])
  end

  def init([batch_size, time_window]) do
    state = Map.new(1..batch_size, fn v -> {v, ""} end)
    state = Map.put(state, :time_window, time_window)
    {:ok, state}
  end

  def handle_cast({:get_time, start_time}, state) do
    state = Map.put(state, :start_time, start_time)
    {:noreply, state}
  end

  def handle_cast({:request_data, batcher_pid, aggregator_pid, tweet_id}, state) do
    Aggregator.check_state(aggregator_pid, batcher_pid, tweet_id)
    {:noreply, state}
  end

  def handle_cast({:collect_data, data}, state) do
    end_time = Time.utc_now
    if Map.has_key?(state, :start_time) and Time.diff(end_time, state[:start_time], :second) >= state.time_window do
      state = Map.delete(state, :start_time)
      Enum.each(Map.delete(state, :time_window), fn {_, tweet_data} ->
        unless tweet_data == "" do
          if Repo.get_by(User, username: tweet_data[:tweet_user]) == nil do
            {:ok, user} = Repo.insert(%User{username: tweet_data[:tweet_user]})
            Repo.insert(%Tweet{tweet: tweet_data[:filtered_tweet], sentiment_score: tweet_data[:sentiment_score], engagement_ratio: tweet_data[:engagement_ratio], user: user})
          else
            user = tweet_data[:tweet_user]
            Repo.insert(%Tweet{tweet: tweet_data[:filtered_tweet], sentiment_score: tweet_data[:sentiment_score], engagement_ratio: tweet_data[:engagement_ratio], user: user})
          end
        end
      end)
      IO.puts("\n-> Batch inserted into database\n")
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
            unless tweet_data[:tweet_user] == nil or tweet_data[:filtered_tweet] == nil or tweet_data[:sentiment_score] == nil or tweet_data[:engagement_ratio] == nil do
              if Repo.get_by(User, username: tweet_data[:tweet_user]) == nil do
                {:ok, user} = Repo.insert(%User{username: tweet_data[:tweet_user]})
                Repo.insert(%Tweet{tweet: tweet_data[:filtered_tweet], sentiment_score: tweet_data[:sentiment_score], engagement_ratio: tweet_data[:engagement_ratio], user: user})
              else
                user = tweet_data[:tweet_user]
                Repo.insert(%Tweet{tweet: tweet_data[:filtered_tweet], sentiment_score: tweet_data[:sentiment_score], engagement_ratio: tweet_data[:engagement_ratio], user: user})
              end
            end
          end)
          IO.puts("\n-> Batch inserted into database\n")
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

  def request_data(batcher_pid, aggregator_pid, tweet_id) do
    GenServer.cast(batcher_pid, {:request_data, batcher_pid, aggregator_pid, tweet_id})
  end

  def collect_data(batcher_pid, data) do
    GenServer.cast(batcher_pid, {:collect_data, data})
  end
end
