defmodule TheStoryVoyageApiWeb.SocialController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Social
  alias TheStoryVoyageApi.Accounts

  action_fallback TheStoryVoyageApiWeb.FallbackController

  # Follows

  def follow(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    target_user = Accounts.get_user!(id)

    with {:ok, _follow} <- Social.follow_user(current_user, target_user) do
      conn
      |> put_status(:created)
      |> json(%{message: "Followed successfully"})
    end
  end

  def unfollow(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    target_user = Accounts.get_user!(id)

    with {:ok, :unfollowed} <- Social.unfollow_user(current_user, target_user) do
      send_resp(conn, :no_content, "")
    end
  end

  def followers(conn, _params) do
    users = Social.list_followers(conn.assigns.current_user)
    render(conn, :index, users: users)
  end

  def following(conn, _params) do
    users = Social.list_following(conn.assigns.current_user)
    render(conn, :index, users: users)
  end

  # Blocks

  def block(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    target_user = Accounts.get_user!(id)

    # In a real app we might return the block object, but here just success message
    with {:ok, _block} <- Social.block_user(current_user, target_user) do
      conn
      |> put_status(:created)
      |> json(%{message: "Blocked successfully"})
    end
  end

  def unblock(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    target_user = Accounts.get_user!(id)

    with {:ok, :unblocked} <- Social.unblock_user(current_user, target_user) do
      send_resp(conn, :no_content, "")
    end
  end

  # Friends

  def send_friend_request(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    target_user = Accounts.get_user!(id)

    with {:ok, request} <- Social.send_friend_request(current_user, target_user) do
      conn
      |> put_status(:created)
      |> render(:request, request: request)
    end
  end

  def list_friend_requests(conn, _params) do
    requests = Social.list_pending_requests(conn.assigns.current_user)
    render(conn, :friend_requests, requests: requests)
  end

  def list_friends(conn, _params) do
    friends = Social.list_friends(conn.assigns.current_user)
    render(conn, :index, users: friends)
  end

  def accept_friend_request(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user

    with {:ok, _} <- Social.accept_friend_request(id, current_user) do
      json(conn, %{message: "Friend request accepted"})
    end
  end

  def reject_friend_request(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user

    with {:ok, _} <- Social.reject_friend_request(id, current_user) do
      json(conn, %{message: "Friend request rejected"})
    end
  end
end
