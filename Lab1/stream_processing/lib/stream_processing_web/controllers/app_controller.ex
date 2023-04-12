defmodule StreamProcessingWeb.AppController do
  use StreamProcessingWeb, :controller

  action_fallback StreamProcessingWeb.FallbackController

  # GET /users
  def display_users(conn, _params) do
    users = StreamProcessing.Data.display_users()
    render(conn, "index.json", users: users)
  end

  # GET /tweets
  def display_tweets(conn, _params) do
    tweets = StreamProcessing.Data.display_tweets()
    render(conn, "index.json", tweets: tweets)
  end

  # GET /users/:id
  def display_user(conn, %{"id" => id}) do
    user = StreamProcessing.Data.get_user!(id)
    render(conn, "show.json", user: user)
  end

  # GET /tweets/:id
  def display_tweet(conn, %{"id" => id}) do
    tweet = StreamProcessing.Data.get_tweet!(id)
    render(conn, "show.json", tweet: tweet)
  end

  # DELETE /users/:id
  def delete_user(conn, %{"id" => id}) do
    movie = StreamProcessing.Data.get_user!(id)
    StreamProcessing.Data.delete_user(movie)
    send_resp(conn, :no_content, "")
  end

  # DELETE /tweets/:id
  def delete_tweet(conn, %{"id" => id}) do
    movie = StreamProcessing.Data.get_tweet!(id)
    StreamProcessing.Data.delete_tweet(movie)
    send_resp(conn, :no_content, "")
  end
end
