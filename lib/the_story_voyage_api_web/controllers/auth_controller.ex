defmodule TheStoryVoyageApiWeb.AuthController do
  @moduledoc """
  Handles user authentication endpoints: registration, login, etc.
  """
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Accounts

  action_fallback TheStoryVoyageApiWeb.FallbackController

  @doc "POST /api/v1/auth/register"
  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{
          user: %{
            id: user.id,
            username: user.username,
            email: user.email,
            display_name: user.display_name,
            role: user.role,
            inserted_at: user.inserted_at
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  def register(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: %{user: ["parameter is required"]}})
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
