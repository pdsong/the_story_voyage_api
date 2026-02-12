defmodule TheStoryVoyageApiWeb.StatsController do
  use TheStoryVoyageApiWeb, :controller
  alias TheStoryVoyageApi.Accounts

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def show(conn, _params) do
    user = conn.assigns.current_user
    stats = Accounts.get_user_stats(user.id)
    render(conn, :show, stats: stats)
  end
end
