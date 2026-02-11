defmodule TheStoryVoyageApi.Token do
  @moduledoc """
  JWT token handling module using Joken.
  """
  use Joken.Config

  @doc """
  Generates a token for the given user.
  """
  def generate_token(user) do
    generate_and_sign(%{
      "user_id" => user.id,
      "role" => user.role
    })
  end

  @doc """
  Verifies a token string.
  """
  def verify_token(token) do
    verify_and_validate(token)
  end

  # Default token configuration
  @impl true
  def token_config do
    # 2 days exp
    default_claims(iss: "TheStoryVoyageApi", aud: "TheStoryVoyageApp", exp: 2 * 24 * 60 * 60)
    |> add_claim("user_id", nil, &(&1 != nil))
    |> add_claim("role", nil, &(&1 in ["user", "librarian", "admin"]))
  end
end
