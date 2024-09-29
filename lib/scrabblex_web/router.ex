defmodule ScrabblexWeb.Router do
  use ScrabblexWeb, :router

  import ScrabblexWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ScrabblexWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ScrabblexWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/", ScrabblexWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :default, on_mount: [ScrabblexWeb.UserLiveAuth, ScrabblexWeb.Nav] do
      live "/matches", MatchLive.Index, :index
      live "/matches/new", MatchLive.Index, :new
      live "/m/:friendly_id", MatchLive.Show, :show
      live "/m/:friendly_id/edit_wildcard/:wildcard_id", MatchLive.Show, :edit_wildcard
      live "/m/:friendly_id/exchange_tiles", MatchLive.Show, :exchange_tiles
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ScrabblexWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:scrabblex, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ScrabblexWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ScrabblexWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ScrabblexWeb.UserAuth, :redirect_if_user_is_authenticated}, ScrabblexWeb.Nav] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ScrabblexWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ScrabblexWeb.UserAuth, :ensure_authenticated}, ScrabblexWeb.Nav] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", ScrabblexWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ScrabblexWeb.UserAuth, :mount_current_user}, ScrabblexWeb.Nav] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/auth/github", ScrabblexWeb do
    pipe_through [:browser]
    get "/", GithubAuthController, :request
    get "/callback", GithubAuthController, :callback
  end
end
