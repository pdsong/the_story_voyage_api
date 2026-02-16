defmodule TheStoryVoyageApiWeb.RecommendationController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Books

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, _params) do
    user = conn.assigns.current_user
    books = Books.get_recommendations(user.id)

    conn
    |> put_view(TheStoryVoyageApiWeb.BookJSON)
    |> render(:index, books: books)
  end
end
