defmodule TheStoryVoyageApiWeb.StatsController do
  use TheStoryVoyageApiWeb, :controller
  alias TheStoryVoyageApi.Stats

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def show(conn, _params) do
    user = conn.assigns.current_user
    stats = Stats.get_overview(user.id)
    render(conn, :show, stats: stats)
  end

  def year(conn, %{"year" => year}) do
    user = conn.assigns.current_user
    stats = Stats.get_year_stats(user.id, year)
    render(conn, :year, stats: stats)
  end

  def genres(conn, _params) do
    user = conn.assigns.current_user
    distribution = Stats.get_genre_distribution(user.id)
    render(conn, :distribution, distribution: distribution)
  end

  def moods(conn, _params) do
    user = conn.assigns.current_user
    distribution = Stats.get_mood_distribution(user.id)
    render(conn, :distribution, distribution: distribution)
  end
end
