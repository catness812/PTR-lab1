defmodule Aggregator do
  use GenServer

  def start do
    IO.puts("-> Aggregator started\n")
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:collect_filtered_tweet, tweet_id, tweet_user, filtered_tweet}, state) do
    if Map.has_key?(state, tweet_id) do
      state = Map.put(state, tweet_id, Map.put(state[tweet_id], :tweet_user, tweet_user))
      state = Map.put(state, tweet_id, Map.put(state[tweet_id], :filtered_tweet, filtered_tweet))
      {:noreply, state}
    else
      state = Map.put(state, tweet_id, %{tweet_user: tweet_user})
      state = Map.put(state, tweet_id, %{filtered_tweet: filtered_tweet})
      {:noreply, state}
    end
  end

  def handle_cast({:collect_sentiment_score, tweet_id, sentiment_score}, state) do
    if Map.has_key?(state, tweet_id) do
      state = Map.put(state, tweet_id, Map.put(state[tweet_id], :sentiment_score, sentiment_score))
      {:noreply, state}
    else
      state = Map.put(state, tweet_id, %{sentiment_score: sentiment_score})
      {:noreply, state}
    end
  end

  def handle_cast({:collect_engagement_ratio, tweet_id, engagement_ratio}, state) do
    if Map.has_key?(state, tweet_id) do
      state = Map.put(state, tweet_id, Map.put(state[tweet_id], :engagement_ratio, engagement_ratio))
      {:noreply, state}
    else
      state = Map.put(state, tweet_id, %{engagement_ratio: engagement_ratio})
      {:noreply, state}
    end
  end

  def handle_cast({:check_state, batcher_pid, tweet_id}, state) do
    if Ecto.Adapters.SQL.Sandbox.checkout(StreamProcessing.Repo) == :ok or Ecto.Adapters.SQL.Sandbox.checkout(StreamProcessing.Repo) == {:already, :owner} do
      case Process.alive?(batcher_pid) do
        true ->
          if Map.has_key?(state, tweet_id) and is_map(state[tweet_id]) do
            if map_size(state[tweet_id]) == 4 do
              Batcher.collect_data(batcher_pid, state[tweet_id])
              {:noreply, state}
            end
          end
        _ ->
          IO.puts("\n-> Batcher not available.\n")
          {:noreply, state}
      end
      {:noreply, state}
    end
  end

  def collect_filtered_tweet(aggregator_pid, tweet_id, tweet_user, filtered_tweet) do
    GenServer.cast(aggregator_pid, {:collect_filtered_tweet, tweet_id, tweet_user, filtered_tweet})
  end

  def collect_sentiment_score(aggregator_pid, tweet_id, sentiment_score) do
    GenServer.cast(aggregator_pid, {:collect_sentiment_score, tweet_id, sentiment_score})
  end

  def collect_engagement_ratio(aggregator_pid, tweet_id, engagement_ratio) do
    GenServer.cast(aggregator_pid, {:collect_engagement_ratio, tweet_id, engagement_ratio})
  end

  def check_state(aggregator_pid, batcher_pid, tweet_id) do
    GenServer.cast(aggregator_pid, {:check_state, batcher_pid, tweet_id})
  end
end
