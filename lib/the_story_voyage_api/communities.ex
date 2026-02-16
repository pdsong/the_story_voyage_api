defmodule TheStoryVoyageApi.Communities do
  @moduledoc """
  The Communities context.
  """

  import Ecto.Query, warn: false
  alias TheStoryVoyageApi.Repo

  alias TheStoryVoyageApi.Communities.{Club, ClubMember, ClubThread, ThreadVote}

  # --- Clubs ---

  def list_clubs do
    Repo.all(Club)
  end

  def list_public_clubs do
    Repo.all(from c in Club, where: c.is_private == false)
  end

  def get_club!(id), do: Repo.get!(Club, id)

  def create_club(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:club, Club.changeset(%Club{owner_id: user.id}, attrs))
    |> Ecto.Multi.insert(:member, fn %{club: club} ->
      ClubMember.changeset(%ClubMember{}, %{
        club_id: club.id,
        user_id: user.id,
        role: "admin",
        status: "joined"
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{club: club}} -> {:ok, club}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def update_club(%Club{} = club, attrs) do
    club
    |> Club.changeset(attrs)
    |> Repo.update()
  end

  def delete_club(%Club{} = club) do
    Repo.delete(club)
  end

  def change_club(%Club{} = club, attrs \\ %{}) do
    Club.changeset(club, attrs)
  end

  # --- Members ---

  def join_club(user, club_id) do
    club = get_club!(club_id)
    status = if club.is_private, do: "pending", else: "joined"

    %ClubMember{}
    |> ClubMember.changeset(%{
      club_id: club.id,
      user_id: user.id,
      role: "member",
      status: status
    })
    |> Repo.insert()
  end

  def list_club_members(club_id) do
    Repo.all(from m in ClubMember, where: m.club_id == ^club_id)
  end

  def is_member?(user_id, club_id) do
    Repo.exists?(
      from m in ClubMember,
        where: m.user_id == ^user_id and m.club_id == ^club_id and m.status == "joined"
    )
  end

  # --- Threads ---

  def list_club_threads(club_id) do
    Repo.all(
      from t in ClubThread,
        where: t.club_id == ^club_id,
        order_by: [desc: t.inserted_at],
        preload: [:creator]
    )
  end

  def get_club_thread!(id), do: Repo.get!(ClubThread, id)

  def create_thread(user, club_id, attrs) do
    if is_member?(user.id, club_id) do
      # Normalize attrs to string keys to avoid mixed keys error
      normalized_attrs = Map.new(attrs, fn {k, v} -> {to_string(k), v} end)
      params = Map.merge(normalized_attrs, %{"club_id" => club_id, "creator_id" => user.id})

      %ClubThread{}
      |> ClubThread.changeset(params)
      |> Repo.insert()
    else
      {:error, :forbidden}
    end
  end

  def update_club_thread(%ClubThread{} = club_thread, attrs) do
    club_thread
    |> ClubThread.changeset(attrs)
    |> Repo.update()
  end

  def delete_club_thread(%ClubThread{} = club_thread) do
    Repo.delete(club_thread)
  end

  def change_club_thread(%ClubThread{} = club_thread, attrs \\ %{}) do
    ClubThread.changeset(club_thread, attrs)
  end

  # --- Votes ---

  def vote_thread(user, thread_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :vote,
      ThreadVote.changeset(%ThreadVote{}, %{user_id: user.id, thread_id: thread_id})
    )
    |> Ecto.Multi.update_all(
      :increment,
      from(t in ClubThread, where: t.id == ^thread_id, update: [inc: [vote_count: 1]]),
      []
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{vote: _vote}} -> {:ok, :voted}
      {:error, :vote, changeset, _} -> {:error, changeset}
    end
  end
end
