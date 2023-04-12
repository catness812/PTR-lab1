defmodule StreamProcessing.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    create table ("users") do
      add :username, :string

      timestamps()
    end

    create table ("tweets") do
      add :user_id, references (:users)
      add :tweet, :text
      add :sentiment_score, :real
      add :engagement_ratio, :real

      timestamps()
    end
  end
end
