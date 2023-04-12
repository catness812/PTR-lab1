defmodule StreamProcessing.Data do
  import Ecto.Query, warn: false

  def display_users do
    StreamProcessing.Repo.all(
    from i in StreamProcessing.Schemas.User,
    order_by: [desc: i.id])
    |> StreamProcessing.Repo.preload(:tweets)
  end

  def display_tweets do
    StreamProcessing.Repo.all(
    from i in StreamProcessing.Schemas.Tweet,
    order_by: [desc: i.id])
    |> StreamProcessing.Repo.preload(:user)
  end

  def get_user!(id) do
    StreamProcessing.Repo.get!(StreamProcessing.Schemas.User, id)
    |> StreamProcessing.Repo.preload(:tweets)
  end

  def get_tweet!(id) do
    StreamProcessing.Repo.get!(StreamProcessing.Schemas.Tweet, id)
    |> StreamProcessing.Repo.preload(:user)
  end

  def delete_user(%StreamProcessing.Schemas.User{} = user) do
    StreamProcessing.Repo.delete(user)
  end

  def delete_tweet(%StreamProcessing.Schemas.Tweet{} = tweet) do
    StreamProcessing.Repo.delete(tweet)
  end
end
