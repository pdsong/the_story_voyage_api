defmodule TheStoryVoyageApiWeb.AuthController do
  @moduledoc """
  Handles user authentication endpoints: registration, login, etc.
  """
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.{Accounts, Token}

  use OpenApiSpex.ControllerSpecs

  tags(["Auth"])

  action_fallback TheStoryVoyageApiWeb.FallbackController

  operation(:login,
    summary: "Login a user",
    parameters: [],
    request_body:
      {"User credentials", "application/json",
       %OpenApiSpex.Schema{
         type: :object,
         properties: %{
           email: %OpenApiSpex.Schema{type: :string},
           password: %OpenApiSpex.Schema{type: :string}
         },
         required: [:email, :password]
       }},
    responses: %{
      200 => {"Login successful", "application/json", TheStoryVoyageApiWeb.Schemas.UserResponse},
      401 => {"Unauthorized", "application/json", %OpenApiSpex.Schema{type: :object}}
    }
  )

  @doc "POST /api/v1/auth/login"
  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Accounts.authenticate_user(email, password),
         {:ok, token, _claims} <- Token.generate_token(user) do
      conn
      |> put_status(:ok)
      |> json(%{
        token: token,
        user: %{
          id: user.id,
          username: user.username,
          email: user.email,
          display_name: user.display_name,
          role: user.role
        }
      })
    end
  end

  operation(:register,
    summary: "Register a new user",
    parameters: [],
    request_body:
      {"User attributes", "application/json", TheStoryVoyageApiWeb.Schemas.UserRegister},
    responses: %{
      201 => {"User created", "application/json", TheStoryVoyageApiWeb.Schemas.UserResponse},
      422 => {"Unprocessable Entity", "application/json", %OpenApiSpex.Schema{type: :object}}
    }
  )

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
