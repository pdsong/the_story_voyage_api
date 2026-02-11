defmodule TheStoryVoyageApiWeb.Router do
  use TheStoryVoyageApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug TheStoryVoyageApiWeb.AuthPlug
  end

  scope "/api/v1", TheStoryVoyageApiWeb do
    pipe_through :api

    # Auth
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/request_reset", PasswordResetController, :create
    post "/auth/reset_password", PasswordResetController, :update

    resources "/books", BookController, only: [:index, :show]
  end

  scope "/api/v1", TheStoryVoyageApiWeb do
    pipe_through [:api, :auth]

    # Protected routes (Logged in users)
    # ... placeholder for user specific routes

    # Admin/Librarian routes
    scope "/books" do
      pipe_through :ensure_admin_or_librarian
      post "/", BookController, :create
      put "/:id", BookController, :update
    end
  end

  pipeline :ensure_admin_or_librarian do
    plug TheStoryVoyageApiWeb.Plugs.RequireRole, ["admin", "librarian"]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:the_story_voyage_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: TheStoryVoyageApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
