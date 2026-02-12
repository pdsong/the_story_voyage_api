defmodule TheStoryVoyageApiWeb.ReviewController do
  use TheStoryVoyageApiWeb, :controller
  alias TheStoryVoyageApi.Accounts

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, %{"book_id" => book_id} = params) do
    reviews = Accounts.list_reviews_for_book(book_id, params)
    render(conn, :index, reviews: reviews)
  end
end
