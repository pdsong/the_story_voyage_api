defmodule TheStoryVoyageApi.Accounts do
  @moduledoc """
  The Accounts context — manages users, follows, blocks, and authentication.
  """
  alias TheStoryVoyageApi.Repo
  alias TheStoryVoyageApi.Accounts.User

  @doc "Returns a user by ID."
  def get_user(id), do: Repo.get(User, id)

  @doc "Returns a user by email."
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc "Returns a user by username."
  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  @doc "Creates a new user with the given attributes."
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a user."
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc "Lists all users (for admin)."
  def list_users do
    Repo.all(User)
  end
end
