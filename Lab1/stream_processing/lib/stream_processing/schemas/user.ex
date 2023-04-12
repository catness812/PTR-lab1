defmodule StreamProcessing.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    has_many :tweets, StreamProcessing.Schemas.Tweet

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username])
    |> validate_required([:username])
  end
end
