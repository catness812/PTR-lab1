defmodule StreamProcessingWeb.Router do
  use StreamProcessingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StreamProcessingWeb do
    pipe_through :api
    get "/users", AppController, :display_users
    get "/tweets", AppController, :display_tweets
    get "/users/:id", AppController, :display_user
    get "/tweets/:id", AppController, :display_tweet
    delete "/users/:id", AppController, :delete_user
    delete "/tweets/:id", AppController, :delete_tweet
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: StreamProcessingWeb.Telemetry
    end
  end
end
