defmodule TheStoryVoyageApiWeb.UserJSON do
  alias TheStoryVoyageApi.Accounts.User

  def me(%{user: user}) do
    %{data: data(user, :private)}
  end

  def show(%{user: user}) do
    %{data: data(user, :public)}
  end

  defp data(%User{} = user, :private) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      display_name: user.display_name,
      bio: user.bio,
      avatar_url: user.avatar_url,
      location: user.location,
      privacy_level: user.privacy_level,
      role: user.role,
      inserted_at: user.inserted_at
    }
  end

  defp data(%User{} = user, :public) do
    %{
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      bio: user.bio,
      avatar_url: user.avatar_url,
      location: user.location,
      privacy_level: user.privacy_level,
      inserted_at: user.inserted_at
    }
  end
end
