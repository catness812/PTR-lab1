defmodule StreamProcessing.Schemas.Tweet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tweets" do
    field :tweet, :string
    field :sentiment_score, :float
    field :engagement_ratio, :float
    belongs_to :user, StreamProcessing.Schemas.User

    timestamps()
  end

  def changeset(tweet, params \\ %{}) do
    tweet
    |> cast(params, [:tweet, :sentiment_score, :engagement_ratio])
    |> validate_required([:tweet, :sentiment_score, :engagement_ratio])
  end
end
