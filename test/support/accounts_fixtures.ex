defmodule TheStoryVoyageApi.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheStoryVoyageApi.Accounts` context.
  """
  alias TheStoryVoyageApi.Accounts

  def unique_user_email, do: "user#{System.unique_integer([:positive])}@example.com"
  def unique_user_username, do: "user#{System.unique_integer([:positive])}"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        username: unique_user_username(),
        email: unique_user_email(),
        password: "password123"
      })
      |> Accounts.register_user()

    user
  end
end
