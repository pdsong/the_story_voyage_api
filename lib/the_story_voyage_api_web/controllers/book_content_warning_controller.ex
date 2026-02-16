defmodule TheStoryVoyageApiWeb.BookContentWarningController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Books
  alias TheStoryVoyageApi.Books.BookContentWarning

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def create(conn, %{"book_id" => book_id, "content_warning_id" => content_warning_id}) do
    user = conn.assigns.current_user
    book = Books.get_book!(book_id)

    with {:ok, %BookContentWarning{} = _bcw} <-
           Books.add_content_warning(book, content_warning_id, user) do
      conn
      |> put_status(:created)
      |> json(%{data: %{message: "Content warning added successfully"}})
    end
  end
end
