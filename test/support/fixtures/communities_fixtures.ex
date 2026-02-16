defmodule TheStoryVoyageApi.CommunitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheStoryVoyageApi.Communities` context.
  """

  @doc """
  Generate a club.
  """
  alias TheStoryVoyageApi.AccountsFixtures
  alias TheStoryVoyageApi.Communities

  def club_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()

    {:ok, club} =
      attrs
      |> Enum.into(%{
        description: "some description",
        is_private: true,
        name: "some name"
      })
      |> then(&Communities.create_club(user, &1))

    club
  end

  # Commenting out other fixtures as they require complex dependencies (club, user)
  # and are not currently used in tests. Can be re-enabled if needed.
end
