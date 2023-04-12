defmodule Printer do
  use GenServer

  def start([lambda, min_sleep_time, max_sleep_time, id]) do
    IO.puts("-> Printer #{id} started\n")
    GenServer.start_link(__MODULE__, [lambda, min_sleep_time, max_sleep_time, id])
  end

  def init([lambda, min_sleep_time, max_sleep_time, id]) do
    {:ok, %{lambda: lambda, min_sleep_time: min_sleep_time, max_sleep_time: max_sleep_time, id: id, tweet_id: 0}}
  end

  def handle_cast({pid, tweet, load_balancer_pid, tweet_redacter_pid, sentiment_score_comp_pid, engagement_ratio_comp_pid, batcher_pid, aggregator_pid}, state) do
    case tweet do
      :kill ->
        IO.puts("-> Printer #{state.id} has received a kill message. Restarting...")
        LoadBalancer.release_worker(load_balancer_pid, state.id, tweet)
        Process.exit(pid, :kill_msg)
        {:noreply, state}
      _ ->
        sleep_time = Statistics.Distributions.Poisson.rand(state.lambda) + state.min_sleep_time
        sleep_time = if sleep_time > state.max_sleep_time, do: state.max_sleep_time, else: sleep_time
        :timer.sleep(trunc(sleep_time))
        state = Map.update(state, :tweet_id, 0, &(&1 + 1))
        tweet_id = state.tweet_id
        TweetRedacter.redact(tweet_redacter_pid, aggregator_pid, batcher_pid, tweet_id, tweet)
        SentimentScoreComp.compute(sentiment_score_comp_pid, aggregator_pid, tweet_id, tweet)
        EngagementRatioComp.compute(engagement_ratio_comp_pid, aggregator_pid, tweet_id, tweet)
        LoadBalancer.release_worker(load_balancer_pid, state.id, tweet)
        {:noreply, state}
    end
  end

  def print(pid, {pid, tweet, load_balancer_pid, tweet_redacter_pid, sentiment_score_comp_pid, engagement_ratio_comp_pid, batcher_pid, aggregator_pid}) do
    GenServer.cast(pid, {pid, tweet, load_balancer_pid, tweet_redacter_pid, sentiment_score_comp_pid, engagement_ratio_comp_pid, batcher_pid, aggregator_pid})
  end
end
