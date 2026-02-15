defmodule TheStoryVoyageApiWeb.SocialJSON do
  alias TheStoryVoyageApi.Accounts.User
  alias TheStoryVoyageApi.Social.FriendRequest

  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  def show(%{user: user}) do
    %{data: data(user)}
  end

  def friend_requests(%{requests: requests}) do
    %{data: for(req <- requests, do: request_data(req))}
  end

  def request(%{request: request}) do
    %{data: request_data(request)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      avatar_url: user.avatar_url
    }
  end

  defp request_data(%{request: %FriendRequest{} = req, sender: %User{} = sender}) do
    %{
      id: req.id,
      status: req.status,
      inserted_at: req.inserted_at,
      sender: data(sender)
    }
  end

  defp request_data(%FriendRequest{} = req) do
    %{
      id: req.id,
      status: req.status,
      inserted_at: req.inserted_at,
      sender_id: req.sender_id,
      receiver_id: req.receiver_id
    }
  end
end
