defmodule TheStoryVoyageApiWeb.UserBookControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _claims} = TheStoryVoyageApi.Token.generate_token(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, user: user}
  end

  describe "index" do
    test "lists all user books", %{conn: conn, user: user} do
      book = book_fixture()
      TheStoryVoyageApi.Accounts.track_book(user, book.id, %{status: "reading"})

      conn = get(conn, ~p"/api/v1/me/books")
      assert json_response(conn, 200)["data"] |> length() == 1
    end
  end

  describe "create" do
    test "tracks a book with valid params", %{conn: conn} do
      book = book_fixture()
      conn = post(conn, ~p"/api/v1/me/books", %{book_id: book.id, status: "reading"})

      assert %{"book_id" => _book_id, "status" => "reading"} = json_response(conn, 201)["data"]
      # Wait, response structure is wrapper around user_book which has book details embeded.
      # Checking logic: UserBookJSON.data returns `book: ...`
    end

    test "updates tracking status", %{conn: conn} do
      book = book_fixture()
      conn = post(conn, ~p"/api/v1/me/books", %{book_id: book.id, status: "reading"})
      conn = post(conn, ~p"/api/v1/me/books", %{book_id: book.id, status: "read"})

      data = json_response(conn, 201)["data"]
      assert data["status"] == "read"
    end
  end

  describe "delete" do
    test "untracks a book", %{conn: conn, user: user} do
      book = book_fixture()
      TheStoryVoyageApi.Accounts.track_book(user, book.id, %{status: "reading"})

      conn = delete(conn, ~p"/api/v1/me/books/#{book.id}")
      assert response(conn, 204)

      assert TheStoryVoyageApi.Accounts.get_user_book(user, book.id) == nil
    end
  end
end
