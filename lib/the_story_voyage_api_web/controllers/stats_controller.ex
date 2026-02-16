defmodule TheStoryVoyageApiWeb.StatsController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Stats

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def show(conn, _params) do
    user = conn.assigns.current_user
    stats = Stats.get_overview(user.id)
    render(conn, :show, stats: stats)
  end

  def year_stats(conn, %{"year" => year} = params) do
    user = conn.assigns.current_user

    if params["compare"] == "true" do
      stats = Stats.get_year_comparison(user.id, year)
      render(conn, :comparison_year, stats: stats)
    else
      stats = Stats.get_year_stats(user.id, year)
      render(conn, :show_year, stats: stats)
    end
  end

  def distribution(conn, %{"type" => "genre"}) do
    user = conn.assigns.current_user
    data = Stats.get_genre_distribution(user.id)
    render(conn, :distribution, data: data)
  end

  def distribution(conn, %{"type" => "mood"}) do
    user = conn.assigns.current_user
    data = Stats.get_mood_distribution(user.id)
    render(conn, :distribution, data: data)
  end

  def comparison(conn, params) do
    user = conn.assigns.current_user
    # Expects from1, to1, from2, to2
    # Simple parsing, in production use a changeset or validation schema

    period1 = %{
      start_date: parse_iso(params["from1"]),
      end_date: parse_iso(params["to1"], :end)
    }

    period2 = %{
      start_date: parse_iso(params["from2"]),
      end_date: parse_iso(params["to2"], :end)
    }

    compare_data = Stats.get_comparison(user.id, period1, period2)
    render(conn, :comparison, stats: compare_data)
  end

  def heatmap(conn, params) do
    user = conn.assigns.current_user
    year = params["year"] || Date.utc_today().year

    data = Stats.get_heatmap_data(user.id, year)
    render(conn, :heatmap, data: data)
  end

  def wrap_up(conn, %{"type" => type, "value" => value}) do
    user = conn.assigns.current_user

    atom_type =
      try do
        String.to_existing_atom(type)
      rescue
        ArgumentError -> :year
      end

    # Restrict to :month or :year
    if atom_type in [:month, :year] do
      summary = Stats.get_wrap_up(user.id, atom_type, value)
      render(conn, :wrap_up, summary: summary)
    else
      send_resp(conn, 400, "Invalid type")
    end
  end

  defp parse_iso(date_str, type \\ :start) do
    date = Date.from_iso8601!(date_str)

    if type == :start do
      DateTime.new!(date, ~T[00:00:00])
    else
      DateTime.new!(date, ~T[23:59:59])
    end
  end
end
