defmodule TheStoryVoyageApiWeb.ReadingGoalController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Challenges
  alias TheStoryVoyageApi.Challenges.ReadingGoal

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, _params) do
    user = conn.assigns.current_user
    reading_goals = Challenges.list_reading_goals(user)
    render(conn, :index, reading_goals: reading_goals)
  end

  def create(conn, %{"reading_goal" => reading_goal_params}) do
    user = conn.assigns.current_user

    with {:ok, %ReadingGoal{} = reading_goal} <-
           Challenges.set_reading_goal(user, reading_goal_params) do
      conn
      |> put_status(:created)
      |> render(:show, reading_goal: reading_goal)
    end
  end
end
