defmodule TheStoryVoyageApiWeb.ReadingGoalJSON do
  alias TheStoryVoyageApi.Challenges.ReadingGoal

  def index(%{reading_goals: reading_goals}) do
    %{data: for(reading_goal <- reading_goals, do: data(reading_goal))}
  end

  def show(%{reading_goal: reading_goal}) do
    %{data: data(reading_goal)}
  end

  def data(%ReadingGoal{} = reading_goal) do
    # Fetch progress dynamically for MVP
    stats = TheStoryVoyageApi.Stats.get_year_stats(reading_goal.user_id, reading_goal.year)

    %{
      id: reading_goal.id,
      year: reading_goal.year,
      target: reading_goal.target,
      progress: stats.book_count,
      user_id: reading_goal.user_id
    }
  end
end
