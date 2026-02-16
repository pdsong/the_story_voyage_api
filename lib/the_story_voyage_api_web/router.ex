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

    # Public routes
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/request_reset", PasswordResetController, :create
    post "/auth/reset_password", PasswordResetController, :update

    get "/books", BookController, :index
    get "/books/:id", BookController, :show

    get "/books/:book_id/reviews", ReviewController, :index
  end

  scope "/api/v1", TheStoryVoyageApiWeb do
    pipe_through [:api, :auth]

    scope "/stats" do
      get "/", StatsController, :show
      get "/compare", StatsController, :comparison
      get "/heatmap", StatsController, :heatmap
      get "/wrap-up", StatsController, :wrap_up
      get "/year/:year", StatsController, :year_stats
      get "/distribution/:type", StatsController, :distribution
    end

    # Protected routes (Logged in users)
    scope "/users" do
      get "/me", UserController, :me
      put "/me", UserController, :update_me

      post "/:id/follow", SocialController, :follow
      delete "/:id/follow", SocialController, :unfollow

      post "/:id/block", SocialController, :block
      delete "/:id/block", SocialController, :unblock

      post "/:id/friend_request", SocialController, :send_friend_request
    end

    # Friend Requests actions
    scope "/friend_requests" do
      put "/:id/accept", SocialController, :accept_friend_request
      put "/:id/reject", SocialController, :reject_friend_request
    end

    scope "/me" do
      get "/books/tags", UserBookController, :list_tags
      get "/books", UserBookController, :index
      post "/books", UserBookController, :create
      delete "/books/:id", UserBookController, :delete

      get "/feed", ActivityController, :index

      get "/notifications", NotificationController, :index
      put "/notifications/:id/read", NotificationController, :mark_read
      put "/notifications/read-all", NotificationController, :mark_all_read

      post "/books/:id/tags", UserBookController, :add_tag
      delete "/books/:id/tags/:tag_name", UserBookController, :remove_tag

      get "/followers", SocialController, :followers
      get "/following", SocialController, :following
      get "/friends", SocialController, :list_friends
      get "/friend_requests", SocialController, :list_friend_requests
    end

    scope "/clubs" do
      get "/", ClubController, :index
      post "/", ClubController, :create
      get "/:id", ClubController, :show
      post "/:id/join", ClubController, :join

      get "/:id/threads", ClubController, :list_threads
      post "/:id/threads", ClubController, :create_thread
      post "/:id/threads/:thread_id/vote", ClubController, :vote_thread
    end

    # Reading Goals
    resources "/reading_goals", ReadingGoalController, only: [:index, :create]

    # Challenges
    resources "/challenges", ChallengeController, only: [:index, :show]
    post "/challenges/:id/join", ChallengeController, :join
    post "/challenges/:id/entries", ChallengeController, :add_entry

    # Buddy Reads
    scope "/buddy_reads" do
      get "/", BuddyReadController, :index
      post "/", BuddyReadController, :create
      get "/:id", BuddyReadController, :show
      post "/:id/join", BuddyReadController, :join
    end

    # Readalongs
    resources "/readalongs", ReadalongController, only: [:index, :create, :show] do
      post "/join", ReadalongController, :join
    end

    scope "/readalong_sections/:section_id" do
      resources "/posts", ReadalongPostController, only: [:index, :create]
    end

    # Admin/Librarian routes
    scope "/books" do
      pipe_through :ensure_admin_or_librarian
      post "/", BookController, :create
      put "/:id", BookController, :update
    end
  end

  scope "/api/v1", TheStoryVoyageApiWeb do
    pipe_through :api

    get "/users/:username", UserController, :show
    get "/users/:username/books", UserController, :books
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
