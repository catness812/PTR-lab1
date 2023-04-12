defmodule SentimentScoreComp do
  use GenServer

  def start do
    IO.puts("-> Sentiment Score Calculator started\n")
    GenServer.start_link(__MODULE__, "http://localhost:4000/emotion_values")
  end

  def init("http://localhost:4000/emotion_values" = emotion_values_endpoint) do
    response = HTTPoison.get(emotion_values_endpoint)
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        emotion_values = body
        |> String.split("\r\n", trim: true)
        |> Enum.reduce(%{}, fn line, acc ->
          [word, value] = String.split(line, "\t")
          Map.put(acc, word, String.to_integer(value))
        end)
        {:ok, %{emotion_values: emotion_values}}
    end
  end

  def handle_cast({:compute, aggregator_pid, tweet_id, tweet}, state) do
    tweet_text = Map.get(tweet, :tweet)
    words = Regex.replace(~r/RT\s.*?:/, tweet_text, "")
        |> String.downcase()
        |> String.split(~r/\s+/)
        |> Enum.filter(&(&1 != ""))
        emotional_score = Enum.reduce(words, 0, fn word, total_score ->
          case Map.get(state.emotion_values, word) do
            nil ->
              total_score
            value ->
              total_score + value
          end
        end)
        sentiment_score = emotional_score / length(words)
        Aggregator.collect_sentiment_score(aggregator_pid, tweet_id, sentiment_score)
    {:noreply, state}
  end

  def compute(sentiment_score_comp_pid, aggregator_pid, tweet_id, tweet) do
    GenServer.cast(sentiment_score_comp_pid, {:compute, aggregator_pid, tweet_id, tweet})
  end
end
