defmodule TheStoryVoyageApiWeb.UserBookController do
  use TheStoryVoyageApiWeb, :controller
  alias TheStoryVoyageApi.Accounts

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, params) do
    user = conn.assigns.current_user
    user_books = Accounts.list_user_books(user, params)
    render(conn, :index, user_books: user_books)
  end

  def create(conn, %{"book_id" => book_id} = params) do
    user = conn.assigns.current_user
    # Status comes from params["status"]

    # Check if we need to remove status from params to pass cleanly or pass whole map?
    # track_book expects attrs, so we can pass params directly if keys match.
    # But usually creating expects "user_book" wrapper? Or direct params?
    # API design says: POST /me/books body: {book_id, status}

    attrs = Map.take(params, ["status", "rating", "notes"])

    with {:ok, user_book} <- Accounts.track_book(user, book_id, attrs) do
      conn
      |> put_status(:created)
      |> render(:show, user_book: user_book)
    end
  end

  def delete(conn, %{"id" => book_id}) do
    user = conn.assigns.current_user

    with {:ok, _} <- Accounts.untrack_book(user, book_id) do
      send_resp(conn, :no_content, "")
    end
  end
end
