defmodule TheStoryVoyageApi.Communities do
  @moduledoc """
  The Communities context.
  """

  import Ecto.Query, warn: false
  alias TheStoryVoyageApi.Repo

  alias TheStoryVoyageApi.Communities.{Club, ClubMember, ClubThread, ThreadVote}
  alias TheStoryVoyageApi.Communities.{BuddyRead, BuddyReadParticipant}
  alias TheStoryVoyageApi.Social

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

  alias TheStoryVoyageApi.Communities.BuddyRead

  @doc """
  Returns the list of buddy_reads visible to the user.
  """
  def list_visible_buddy_reads(user) do
    participant_buddy_read_ids =
      from(p in BuddyReadParticipant, where: p.user_id == ^user.id, select: p.buddy_read_id)

    friend_ids_query =
      from(uf in TheStoryVoyageApi.Social.UserFollow,
        where: uf.follower_id == ^user.id and uf.is_friend == true,
        select: uf.followed_id
      )

    query =
      from b in BuddyRead,
        where:
          b.id in subquery(participant_buddy_read_ids) or
            b.creator_id in subquery(friend_ids_query) or
            b.creator_id == ^user.id,
        order_by: [desc: b.inserted_at],
        preload: [:book, :creator]

    Repo.all(query)
  end

  def get_buddy_read!(id) do
    buddy_read = Repo.get!(BuddyRead, id) |> Repo.preload([:book, :creator])

    participants =
      Repo.all(from p in BuddyReadParticipant, where: p.buddy_read_id == ^id, preload: [:user])

    Map.put(buddy_read, :participants, participants)
  end

  def create_buddy_read(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :buddy_read,
      BuddyRead.changeset(%BuddyRead{creator_id: user.id}, attrs)
    )
    |> Ecto.Multi.insert(:participant, fn %{buddy_read: buddy_read} ->
      BuddyReadParticipant.changeset(struct(BuddyReadParticipant), %{
        buddy_read_id: buddy_read.id,
        user_id: user.id
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{buddy_read: buddy_read}} -> {:ok, buddy_read}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def join_buddy_read(user, buddy_read_id) do
    buddy_read = Repo.get(BuddyRead, buddy_read_id)

    if buddy_read do
      count =
        Repo.aggregate(
          from(p in BuddyReadParticipant, where: p.buddy_read_id == ^buddy_read.id),
          :count,
          :id
        )

      is_creator = buddy_read.creator_id == user.id
      is_friend = Social.is_friend?(user.id, buddy_read.creator_id)

      cond do
        count >= 9 ->
          {:error, :full}

        not (is_creator or is_friend) ->
          {:error, :forbidden}

        true ->
          struct(BuddyReadParticipant)
          |> BuddyReadParticipant.changeset(%{
            buddy_read_id: buddy_read.id,
            user_id: user.id
          })
          |> Repo.insert()
      end
    else
      {:error, :not_found}
    end
  end

  @doc """
  Updates a buddy_read.

  ## Examples

      iex> update_buddy_read(buddy_read, %{field: new_value})
      {:ok, %BuddyRead{}}

      iex> update_buddy_read(buddy_read, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_buddy_read(%BuddyRead{} = buddy_read, attrs) do
    buddy_read
    |> BuddyRead.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a buddy_read.

  ## Examples

      iex> delete_buddy_read(buddy_read)
      {:ok, %BuddyRead{}}

      iex> delete_buddy_read(buddy_read)
      {:error, %Ecto.Changeset{}}

  """
  def delete_buddy_read(%BuddyRead{} = buddy_read) do
    Repo.delete(buddy_read)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking buddy_read changes.

  ## Examples

      iex> change_buddy_read(buddy_read)
      %Ecto.Changeset{data: %BuddyRead{}}

  """
  def change_buddy_read(%BuddyRead{} = buddy_read, attrs \\ %{}) do
    BuddyRead.changeset(buddy_read, attrs)
  end

  alias TheStoryVoyageApi.Communities.BuddyReadParticipant

  @doc """
  Returns the list of buddy_read_participants.

  ## Examples

      iex> list_buddy_read_participants()
      [%BuddyReadParticipant{}, ...]

  """
  def list_buddy_read_participants do
    Repo.all(BuddyReadParticipant)
  end

  @doc """
  Gets a single buddy_read_participant.

  Raises `Ecto.NoResultsError` if the Buddy read participant does not exist.

  ## Examples

      iex> get_buddy_read_participant!(123)
      %BuddyReadParticipant{}

      iex> get_buddy_read_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_buddy_read_participant!(id), do: Repo.get!(BuddyReadParticipant, id)

  @doc """
  Creates a buddy_read_participant.

  ## Examples

      iex> create_buddy_read_participant(%{field: value})
      {:ok, %BuddyReadParticipant{}}

      iex> create_buddy_read_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_buddy_read_participant(attrs) do
    %BuddyReadParticipant{}
    |> BuddyReadParticipant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a buddy_read_participant.

  ## Examples

      iex> update_buddy_read_participant(buddy_read_participant, %{field: new_value})
      {:ok, %BuddyReadParticipant{}}

      iex> update_buddy_read_participant(buddy_read_participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_buddy_read_participant(%BuddyReadParticipant{} = buddy_read_participant, attrs) do
    buddy_read_participant
    |> BuddyReadParticipant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a buddy_read_participant.

  ## Examples

      iex> delete_buddy_read_participant(buddy_read_participant)
      {:ok, %BuddyReadParticipant{}}

      iex> delete_buddy_read_participant(buddy_read_participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_buddy_read_participant(%BuddyReadParticipant{} = buddy_read_participant) do
    Repo.delete(buddy_read_participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking buddy_read_participant changes.

  ## Examples

      iex> change_buddy_read_participant(buddy_read_participant)
      %Ecto.Changeset{data: %BuddyReadParticipant{}}

  """
  def change_buddy_read_participant(
        %BuddyReadParticipant{} = buddy_read_participant,
        attrs \\ %{}
      ) do
    BuddyReadParticipant.changeset(buddy_read_participant, attrs)
  end

  alias TheStoryVoyageApi.Communities.{
    Readalong,
    ReadalongSection,
    ReadalongParticipant,
    ReadalongPost
  }

  # --- Readalongs ---

  def list_readalongs do
    Repo.all(from r in Readalong, preload: [:book, :owner], order_by: [desc: r.start_date])
  end

  def get_readalong!(id) do
    Repo.get!(Readalong, id)
    |> Repo.preload([
      :book,
      :owner,
      sections: from(s in ReadalongSection, order_by: s.unlock_date)
    ])
  end

  def create_readalong(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:readalong, fn _ ->
      %Readalong{owner_id: user.id}
      |> Readalong.changeset(attrs)
    end)
    |> Ecto.Multi.insert(:participant, fn %{readalong: readalong} ->
      ReadalongParticipant.changeset(%ReadalongParticipant{}, %{
        readalong_id: readalong.id,
        user_id: user.id
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{readalong: readalong}} -> {:ok, readalong}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def join_readalong(user, readalong_id) do
    %ReadalongParticipant{}
    |> ReadalongParticipant.changeset(%{readalong_id: readalong_id, user_id: user.id})
    |> Repo.insert()
  end

  def is_readalong_participant?(user_id, readalong_id) do
    Repo.exists?(
      from rp in ReadalongParticipant,
        where: rp.user_id == ^user_id and rp.readalong_id == ^readalong_id
    )
  end

  # --- Readalong Sections/Posts ---

  def get_readalong_section!(id), do: Repo.get!(ReadalongSection, id)

  def list_readalong_posts(section_id) do
    Repo.all(
      from p in ReadalongPost,
        where: p.readalong_section_id == ^section_id,
        order_by: [asc: p.inserted_at],
        preload: [:user]
    )
  end

  def create_readalong_post(user, section_id, attrs) do
    section = get_readalong_section!(section_id)

    if DateTime.compare(DateTime.utc_now(), section.unlock_date) == :lt do
      {:error, :locked}
    else
      # Normalize attrs to string keys
      normalized_attrs = Map.new(attrs, fn {k, v} -> {to_string(k), v} end)

      params =
        Map.merge(normalized_attrs, %{"user_id" => user.id, "readalong_section_id" => section_id})

      %ReadalongPost{}
      |> ReadalongPost.changeset(params)
      |> Repo.insert()
    end
  end
end
