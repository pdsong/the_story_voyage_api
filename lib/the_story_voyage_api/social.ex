defmodule TheStoryVoyageApi.Social do
  @moduledoc """
  The Social context.
  """
  import Ecto.Query, warn: false
  alias TheStoryVoyageApi.Repo

  alias TheStoryVoyageApi.Social.UserFollow
  alias TheStoryVoyageApi.Social.UserBlock
  alias TheStoryVoyageApi.Social.FriendRequest
  alias TheStoryVoyageApi.Accounts.User

  ## Follows

  def follow_user(%User{id: follower_id}, %User{id: followed_id}) do
    if follower_id == followed_id do
      {:error, :cannot_follow_self}
    else
      %UserFollow{}
      |> UserFollow.changeset(%{follower_id: follower_id, followed_id: followed_id})
      |> Repo.insert()
    end
  end

  def unfollow_user(%User{id: follower_id}, %User{id: followed_id}) do
    from(uf in UserFollow,
      where: uf.follower_id == ^follower_id and uf.followed_id == ^followed_id
    )
    |> Repo.delete_all()

    {:ok, :unfollowed}
  end

  def following?(follower_id, followed_id) do
    Repo.exists?(
      from uf in UserFollow,
        where: uf.follower_id == ^follower_id and uf.followed_id == ^followed_id
    )
  end

  def list_followers(%User{} = user) do
    Repo.all(
      from u in User,
        join: uf in UserFollow,
        on: uf.follower_id == u.id,
        where: uf.followed_id == ^user.id,
        select: u
    )
  end

  def list_following(%User{} = user) do
    Repo.all(
      from u in User,
        join: uf in UserFollow,
        on: uf.followed_id == u.id,
        where: uf.follower_id == ^user.id,
        select: u
    )
  end

  ## Blocks

  def block_user(%User{id: blocker_id}, %User{id: blocked_id}) do
    if blocker_id == blocked_id do
      {:error, :cannot_block_self}
    else
      Repo.transaction(fn ->
        # 1. Create block
        %UserBlock{}
        |> UserBlock.changeset(%{blocker_id: blocker_id, blocked_id: blocked_id})
        |> Repo.insert!()

        # 2. Auto-unfollow (both directions)
        unfollow_user(%User{id: blocker_id}, %User{id: blocked_id})
        unfollow_user(%User{id: blocked_id}, %User{id: blocker_id})

        # 3. Cancel friend requests (both directions)
        from(fr in FriendRequest,
          where:
            (fr.sender_id == ^blocker_id and fr.receiver_id == ^blocked_id) or
              (fr.sender_id == ^blocked_id and fr.receiver_id == ^blocker_id)
        )
        |> Repo.delete_all()
      end)
    end
  end

  def unblock_user(%User{id: blocker_id}, %User{id: blocked_id}) do
    from(ub in UserBlock, where: ub.blocker_id == ^blocker_id and ub.blocked_id == ^blocked_id)
    |> Repo.delete_all()

    {:ok, :unblocked}
  end

  def blocking?(blocker_id, blocked_id) do
    Repo.exists?(
      from ub in UserBlock, where: ub.blocker_id == ^blocker_id and ub.blocked_id == ^blocked_id
    )
  end

  ## Friends

  def send_friend_request(%User{id: sender_id}, %User{id: receiver_id}) do
    if sender_id == receiver_id do
      {:error, :cannot_friend_self}
    else
      if blocking?(receiver_id, sender_id) or blocking?(sender_id, receiver_id) do
        {:error, :blocked}
      else
        %FriendRequest{}
        |> FriendRequest.changeset(%{
          sender_id: sender_id,
          receiver_id: receiver_id,
          status: "pending"
        })
        |> Repo.insert()
      end
    end
  end

  def accept_friend_request(request_id, %User{id: receiver_id}) do
    request = Repo.get(FriendRequest, request_id)

    cond do
      is_nil(request) ->
        {:error, :not_found}

      request.receiver_id != receiver_id ->
        {:error, :unauthorized}

      request.status != "pending" ->
        {:error, :already_processed}

      true ->
        Repo.transaction(fn ->
          # 1. Update request status
          request
          |> FriendRequest.changeset(%{status: "accepted"})
          |> Repo.update!()

          # 2. Auto-follow mutually (optional but common for friends logic,
          # allows feed to work easily. Or we can rely on is_friend logic.
          # Let's auto-follow for simpler feed logic in F13)

          # Check and create follow A -> B
          unless following?(request.sender_id, request.receiver_id) do
            %UserFollow{}
            |> UserFollow.changeset(%{
              follower_id: request.sender_id,
              followed_id: request.receiver_id,
              is_friend: true
            })
            |> Repo.insert!()
          end

          # Check and create follow B -> A
          unless following?(request.receiver_id, request.sender_id) do
            %UserFollow{}
            |> UserFollow.changeset(%{
              follower_id: request.receiver_id,
              followed_id: request.sender_id,
              is_friend: true
            })
            |> Repo.insert!()
          end

          # Update existing follows to be friends if they existed
          from(uf in UserFollow,
            where:
              (uf.follower_id == ^request.sender_id and uf.followed_id == ^request.receiver_id) or
                (uf.follower_id == ^request.receiver_id and uf.followed_id == ^request.sender_id)
          )
          |> Repo.update_all(set: [is_friend: true])
        end)
    end
  end

  def reject_friend_request(request_id, %User{id: receiver_id}) do
    request = Repo.get(FriendRequest, request_id)

    cond do
      is_nil(request) ->
        {:error, :not_found}

      request.receiver_id != receiver_id ->
        {:error, :unauthorized}

      true ->
        # We can either delete it or mark as rejected.
        # Requirement says "Relationship not established".
        # Let's delete it to allow re-request later or mark rejected?.
        # Typically rejected requests can be re-sent after some time.
        # Let's mark rejected for history or delete? The plan implies simple refusal.
        # Let's delete logic for simplicity or set status rejected.

        request
        |> FriendRequest.changeset(%{status: "rejected"})
        |> Repo.update()
    end
  end

  def list_pending_requests(%User{} = user) do
    Repo.all(
      from fr in FriendRequest,
        join: sender in User,
        on: fr.sender_id == sender.id,
        where: fr.receiver_id == ^user.id and fr.status == "pending",
        select: %{request: fr, sender: sender}
    )
  end

  def list_friends(%User{} = user) do
    # Friends are those with is_friend: true in UserFollow
    Repo.all(
      from u in User,
        join: uf in UserFollow,
        on: uf.followed_id == u.id,
        where: uf.follower_id == ^user.id and uf.is_friend == true,
        select: u
    )
  end

  alias TheStoryVoyageApi.Social.Activity

  ## Activities

  def create_activity(user, type, data \\ %{}) do
    book_id = data["book_id"] || data[:book_id]

    %Activity{}
    |> Activity.changeset(%{
      user_id: user.id,
      type: type,
      data: data,
      book_id: book_id
    })
    |> Repo.insert()
  end

  def list_feed(%User{} = user, params \\ %{}) do
    following_ids =
      from(uf in UserFollow, where: uf.follower_id == ^user.id, select: uf.followed_id)

    query =
      from a in Activity,
        where: a.user_id in subquery(following_ids),
        order_by: [desc: a.inserted_at],
        preload: [:user, book: [:authors, :genres, :moods]]

    page = params["page"] || 1
    page_size = 20
    offset = (String.to_integer(to_string(page)) - 1) * page_size

    query = from a in query, limit: ^page_size, offset: ^offset

    Repo.all(query)
  end
end
