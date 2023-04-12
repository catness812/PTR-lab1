defmodule TweetRedacter do
  use GenServer

  def start do
    IO.puts("-> Tweet Redacter started\n")
    GenServer.start_link(__MODULE__, "lib/bad_words.json")
  end

  def init("lib/bad_words.json" = path) do
    bad_words = File.read!(path) |> Jason.decode!()
    {:ok, %{bad_words: bad_words}}
  end

  def handle_cast({:redact, aggregator_pid, batcher_pid, tweet_id, tweet}, state) do
    tweet_user = Map.get(tweet, :user)
    tweet_text = Map.get(tweet, :tweet)
    filtered_tweet = Enum.reduce(state.bad_words, tweet_text, fn bad_word, acc ->
      String.replace(acc, bad_word, String.duplicate("*", String.length(bad_word)))
    end)
    Aggregator.collect_filtered_tweet(aggregator_pid, tweet_id, tweet_user, filtered_tweet)
    Batcher.request_data(batcher_pid, aggregator_pid, tweet_id)
    {:noreply, state}
  end

  def redact(tweet_redacter_pid, aggregator_pid, batcher_pid, tweet_id, tweet) do
    GenServer.cast(tweet_redacter_pid, {:redact, aggregator_pid, batcher_pid, tweet_id, tweet})
  end
end
