defmodule TheStoryVoyageApiWeb.ActivityController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Social

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, params) do
    user = conn.assigns.current_user
    activities = Social.list_feed(user, params)
    render(conn, :index, activities: activities)
  end
end
