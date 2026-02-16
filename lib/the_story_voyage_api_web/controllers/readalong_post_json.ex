defmodule TheStoryVoyageApiWeb.ReadalongPostJSON do
  alias TheStoryVoyageApi.Communities.ReadalongPost

  @doc """
  Renders a list of readalong_posts.
  """
  def index(%{posts: posts}) do
    %{data: for(post <- posts, do: data(post))}
  end

  @doc """
  Renders a single readalong_post.
  """
  def show(%{post: post}) do
    %{data: data(post)}
  end

  defp data(%ReadalongPost{} = post) do
    %{
      id: post.id,
      content: post.content,
      readalong_section_id: post.readalong_section_id,
      user_id: post.user_id,
      user: user_data(post.user),
      inserted_at: post.inserted_at
    }
  end

  defp user_data(%Ecto.Association.NotLoaded{}), do: nil
  defp user_data(nil), do: nil

  defp user_data(user) do
    %{
      id: user.id,
      username: user.username,
      avatar_url: user.avatar_url
    }
  end
end
