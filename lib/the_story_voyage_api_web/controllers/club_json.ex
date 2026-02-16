defmodule TheStoryVoyageApiWeb.ClubJSON do
  alias TheStoryVoyageApi.Communities.{Club, ClubThread}

  @doc """
  Renders a list of clubs.
  """
  def index(%{clubs: clubs}) do
    %{data: for(club <- clubs, do: data(club))}
  end

  @doc """
  Renders a single club.
  """
  def show(%{club: club}) do
    %{data: data(club)}
  end

  def index_threads(%{threads: threads}) do
    %{data: for(thread <- threads, do: thread_data(thread))}
  end

  def show_thread(%{thread: thread}) do
    %{data: thread_data(thread)}
  end

  defp data(%Club{} = club) do
    %{
      id: club.id,
      name: club.name,
      description: club.description,
      is_private: club.is_private,
      owner_id: club.owner_id
    }
  end

  defp thread_data(%ClubThread{} = thread) do
    %{
      id: thread.id,
      title: thread.title,
      content: thread.content,
      vote_count: thread.vote_count,
      creator_id: thread.creator_id,
      inserted_at: thread.inserted_at
    }
  end
end
