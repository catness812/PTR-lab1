defmodule StreamProcessing.Repo do
  use Ecto.Repo,
    otp_app: :stream_processing,
    adapter: Ecto.Adapters.Postgres
end
