defmodule StreamProcessingWeb.AppView do
  use StreamProcessingWeb, :view
  alias StreamProcessingWeb.AppView

  def render("index.json", %{users: users}) do
    %{data: Enum.map(users, &render_user/1)}
  end

  def render("index.json", %{tweets: tweets}) do
    %{data: Enum.map(tweets, &render_tweet/1)}
  end

  def render("show.json", %{user: user}) do
    %{data: render_user(user)}
  end

  defp render_user(user) do
    %{
      user_id: user.id,
      user_name: user.username,
      user_tweets: Enum.map(user.tweets, &render_user_tweet/1)
    }
  end

  defp render_user_tweet(tweet) do
    %{
      tweet_id: tweet.id,
      tweet_text: tweet.tweet
    }
  end

  def render("show.json", %{tweet: tweet}) do
    %{data: render_tweet(tweet)}
  end

  defp render_tweet(tweet) do
    %{
      tweet_id: tweet.id,
      tweet_text: tweet.tweet,
      sentiment_score: tweet.sentiment_score,
      engagement_ratio: tweet.engagement_ratio,
      user_id: tweet.user_id,
      user_name: tweet.user.username
    }
  end
end
