defmodule Printer do
  use GenServer

  def start([lambda, min_sleep_time, max_sleep_time, id]) do
    IO.puts("-> Printer #{id} started\n")
    GenServer.start_link(__MODULE__, [lambda, min_sleep_time, max_sleep_time, id])
  end

  def init([lambda, min_sleep_time, max_sleep_time, id]) do
    {:ok, %{lambda: lambda, min_sleep_time: min_sleep_time, max_sleep_time: max_sleep_time, id: id}}
  end

  def handle_cast({pid, tweet, load_balancer_pid, tweet_redacter_pid, sentiment_score_comp_pid, engagement_ratio_comp_pid}, state) do
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
        filtered_tweet = TweetRedacter.redact(tweet_redacter_pid, tweet)
        sentiment_score = SentimentScoreComp.compute(sentiment_score_comp_pid, tweet)
        engagement_ratio = EngagementRatioComp.compute(engagement_ratio_comp_pid, tweet)
        IO.puts("Tweet:\n#{filtered_tweet}\nSentiment Score: #{sentiment_score}\nEngagement Ratio: #{engagement_ratio}\n")
        LoadBalancer.release_worker(load_balancer_pid, state.id, tweet)
        {:noreply, state}
    end
  end

  def print(pid, {pid, tweet, load_balancer_pid, tweet_redacter_pid, sentiment_score_comp_pid, engagement_ratio_comp_pid}) do
    GenServer.cast(pid, {pid, tweet, load_balancer_pid, tweet_redacter_pid, sentiment_score_comp_pid, engagement_ratio_comp_pid})
  end
end
