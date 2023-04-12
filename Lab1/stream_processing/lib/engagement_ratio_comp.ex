defmodule EngagementRatioComp do
  use GenServer

  def start do
    IO.puts("-> Engagement Ratio Calculator started\n")
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:compute, aggregator_pid, tweet_id, tweet}, state) do
    if Map.get(tweet, :followers) != 0 do
      engagement_ratio = (Map.get(tweet, :favorites) + Map.get(tweet, :retweets)) / Map.get(tweet, :followers)
      Aggregator.collect_engagement_ratio(aggregator_pid, tweet_id, engagement_ratio)
      {:noreply, state}
    else
      engagement_ratio = 0.0
      Aggregator.collect_engagement_ratio(aggregator_pid, tweet_id, engagement_ratio)
      {:noreply, state}
    end
  end

  def compute(engagement_ratio_comp_pid, aggregator_pid, tweet_id, tweet) do
    GenServer.cast(engagement_ratio_comp_pid, {:compute, aggregator_pid, tweet_id, tweet})
  end
end
