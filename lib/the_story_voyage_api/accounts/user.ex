defmodule TheStoryVoyageApi.Accounts.User do
  @moduledoc """
  Schema for the users table.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string
    field :display_name, :string
    field :bio, :string
    field :avatar_url, :string
    field :location, :string
    field :privacy_level, :string, default: "public"
    field :role, :string, default: "user"
    field :reset_password_token, :string
    field :reset_password_sent_at, :utc_datetime

    has_many :user_books, TheStoryVoyageApi.Accounts.UserBook
    has_many :books, through: [:user_books, :book]

    # Virtual field for password input (not stored)
    field :password, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @required_fields [:username, :email, :password_hash]
  @optional_fields [
    :display_name,
    :bio,
    :avatar_url,
    :location,
    :privacy_level,
    :role,
    :reset_password_token,
    :reset_password_sent_at
  ]

  @doc "Changeset for creating/updating a user (admin or internal)."
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:username, min: 3, max: 30)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_inclusion(:privacy_level, ["public", "friends_only", "private"])
    |> validate_inclusion(:role, ["user", "librarian", "admin"])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc "Changeset for user registration (takes plain password)."
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> validate_length(:username, min: 3, max: 30)
    |> validate_length(:password, min: 8, max: 100)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> hash_password()
  end

  @doc "Changeset for resetting password."
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 100)
    |> hash_password()
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset

      password ->
        changeset
        |> put_change(:password_hash, Bcrypt.hash_pwd_salt(password))
        |> delete_change(:password)
    end
  end
end
