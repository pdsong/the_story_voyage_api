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

  @doc "Authenticates a user by email and password."
  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Bcrypt.no_user_verify()
        {:error, :unauthorized}
    end
  end

  @doc "Creates a new user with registration changeset (hashes password)."
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc "Creates a new user with the given attributes (admin/internal)."
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

  @doc "Gets a user by reset token."
  def get_user_by_reset_token(token) do
    Repo.get_by(User, reset_password_token: token)
  end

  @doc "Generates a reset token for the user."
  def create_reset_token(user) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

    user
    |> User.changeset(%{
      reset_password_token: token,
      reset_password_sent_at: DateTime.utc_now()
    })
    |> Repo.update()
  end

  @doc "Resets the user password."
  @doc "Resets the user password."
  def reset_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> User.changeset(%{
      reset_password_token: nil,
      reset_password_sent_at: nil
    })
    |> Repo.update()
  end

  @doc "Lists all users (for admin)."
  def list_users do
    Repo.all(User)
  end
end
