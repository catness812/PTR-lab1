# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :stream_processing,
  ecto_repos: [StreamProcessing.Repo]

# Configures the endpoint
config :stream_processing, StreamProcessingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IoUApPZhzDfLWA61C+8RGNkvIyyInCp3jZeM+fiJCq4nV/d5mKFEAfXR1uoBFlti",
  render_errors: [view: StreamProcessingWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: StreamProcessing.PubSub,
  live_view: [signing_salt: "hL7+Vk2M"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
