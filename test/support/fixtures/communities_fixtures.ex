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

  alias TheStoryVoyageApi.BooksFixtures

  @doc """
  Generate a buddy_read.
  """
  def buddy_read_fixture(attrs \\ %{}) do
    creator = attrs[:creator] || AccountsFixtures.user_fixture()
    book = attrs[:book] || BooksFixtures.book_fixture()

    {:ok, buddy_read} =
      attrs
      |> Enum.into(%{
        start_date: ~D[2026-02-15],
        status: "active",
        book_id: book.id
      })
      |> then(&Communities.create_buddy_read(creator, &1))

    # Reload to get preloads if needed
    Communities.get_buddy_read!(buddy_read.id)
  end

  @doc """
  Generate a buddy_read_participant.
  """
  def buddy_read_participant_fixture(attrs \\ %{}) do
    # This is usually handled by create_buddy_read or join_buddy_read
    # But if we need a standalone fixture:
    user = attrs[:user] || AccountsFixtures.user_fixture()
    buddy_read = attrs[:buddy_read] || buddy_read_fixture()

    {:ok, participant} =
      Communities.join_buddy_read(user, buddy_read.id)

    participant
  end
end
