defmodule TheStoryVoyageApiWeb.UserController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Accounts

  action_fallback TheStoryVoyageApiWeb.FallbackController

  # GET /me
  def me(conn, _params) do
    user = conn.assigns.current_user
    render(conn, :me, user: user)
  end

  # PUT /me
  def update_me(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    with {:ok, %Accounts.User{} = updated_user} <- Accounts.update_user_profile(user, user_params) do
      render(conn, :me, user: updated_user)
    end
  end

  # GET /users/:username
  def show(conn, %{"username" => username}) do
    case Accounts.get_public_user(username) do
      nil ->
        {:error, :not_found}

      user ->
        # Privacy check could be here. For now, public profile shows basic info.
        # If privacy_level is private, maybe show less?
        # For MVP, we return public view which excludes email/role.
        render(conn, :show, user: user)
    end
  end

  # GET /users/:username/books
  def books(conn, %{"username" => username} = params) do
    case Accounts.get_public_user(username) do
      nil ->
        {:error, :not_found}

      user ->
        # Check privacy
        # For MVP: if private, return forbidden unless it's me?
        # Let's verify if user is me.
        current_user = conn.assigns[:current_user]
        is_me = current_user && current_user.id == user.id

        if user.privacy_level == "private" and not is_me do
          conn
          |> put_status(:forbidden)
          |> json(%{error: "This user's bookshelf is private"})
        else
          books = Accounts.list_user_books(user, params)
          render(conn, TheStoryVoyageApiWeb.UserBookJSON, :index, user_books: books)
        end
    end
  end
end
