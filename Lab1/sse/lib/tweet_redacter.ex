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

  def handle_call({:redact, tweet}, _from, state) do
    tweet_text = Map.get(tweet, :tweet)
    filtered_tweet = Enum.reduce(state.bad_words, tweet_text, fn bad_word, acc ->
      String.replace(acc, bad_word, String.duplicate("*", String.length(bad_word)))
    end)
    {:reply, filtered_tweet, state}
  end

  def redact(tweet_redacter_pid, tweet) do
    GenServer.call(tweet_redacter_pid, {:redact, tweet})
  end
end
