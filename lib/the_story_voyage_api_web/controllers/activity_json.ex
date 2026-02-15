defmodule TheStoryVoyageApiWeb.ActivityJSON do
  alias TheStoryVoyageApi.Social.Activity
  alias TheStoryVoyageApiWeb.UserJSON
  alias TheStoryVoyageApiWeb.BookJSON

  @doc """
  Renders a list of activities.
  """
  def index(%{activities: activities}) do
    %{data: for(activity <- activities, do: data(activity))}
  end

  @doc """
  Renders a single activity.
  """
  def show(%{activity: activity}) do
    %{data: data(activity)}
  end

  def data(%Activity{} = activity) do
    %{
      id: activity.id,
      type: activity.type,
      data: activity.data,
      inserted_at: activity.inserted_at,
      user_id: activity.user_id,
      user: if(Ecto.assoc_loaded?(activity.user), do: UserJSON.data(activity.user), else: nil),
      book_id: activity.book_id,
      book:
        if(Ecto.assoc_loaded?(activity.book) && activity.book,
          do: BookJSON.data(activity.book),
          else: nil
        )
    }
  end
end
