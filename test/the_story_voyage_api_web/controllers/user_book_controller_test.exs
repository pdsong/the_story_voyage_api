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

  describe "tags" do
    test "add_tag adds a tag", %{conn: conn, user: user} do
      book = book_fixture()
      TheStoryVoyageApi.Accounts.track_book(user, book.id, %{status: "reading"})

      conn = post(conn, ~p"/api/v1/me/books/#{book.id}/tags", %{tag: "summer-2025"})
      assert json_response(conn, 201)["message"] == "Tag added successfully"
    end

    test "remove_tag removes a tag", %{conn: conn, user: user} do
      book = book_fixture()

      {:ok, user_book} =
        TheStoryVoyageApi.Accounts.track_book(user, book.id, %{status: "reading"})

      TheStoryVoyageApi.Reading.add_tag(user_book, "summer-2025")

      conn = delete(conn, ~p"/api/v1/me/books/#{book.id}/tags/summer-2025")
      assert response(conn, 204)
    end

    test "list_tags lists user tags", %{conn: conn, user: user} do
      book = book_fixture()

      {:ok, user_book} =
        TheStoryVoyageApi.Accounts.track_book(user, book.id, %{status: "reading"})

      TheStoryVoyageApi.Reading.add_tag(user_book, "summer-2025")

      conn = get(conn, ~p"/api/v1/me/books/tags")
      assert json_response(conn, 200)["data"] == ["summer-2025"]
    end

    test "index filters by tag", %{conn: conn, user: user} do
      book1 = book_fixture()
      {:ok, ub1} = TheStoryVoyageApi.Accounts.track_book(user, book1.id, %{status: "reading"})
      TheStoryVoyageApi.Reading.add_tag(ub1, "tag1")

      book2 = book_fixture()
      TheStoryVoyageApi.Accounts.track_book(user, book2.id, %{status: "reading"})
      # No tag for book2

      conn = get(conn, ~p"/api/v1/me/books", tag: "tag1")
      data = json_response(conn, 200)["data"]
      assert length(data) == 1
      assert hd(data)["book_id"] == book1.id
    end
  end
end
