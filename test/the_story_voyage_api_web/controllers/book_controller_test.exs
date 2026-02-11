defmodule TheStoryVoyageApiWeb.BookControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  alias TheStoryVoyageApi.Books
  alias TheStoryVoyageApi.Accounts

  setup %{conn: conn} do
    genre = Books.create_genre(%{name: "Test Genre", slug: "test-genre"}) |> elem(1)
    author = Books.create_author(%{name: "Test Author"}) |> elem(1)

    {:ok, admin} =
      Accounts.register_user(%{
        username: "admin",
        email: "admin@test.com",
        password: "password123"
      })

    {:ok, admin} = Accounts.update_user(admin, %{role: "admin"})

    {:ok, user} =
      Accounts.register_user(%{
        username: "user",
        email: "user@test.com",
        password: "password123"
      })

    {:ok, admin_token, _} = TheStoryVoyageApi.Token.generate_token(admin)
    {:ok, user_token, _} = TheStoryVoyageApi.Token.generate_token(user)

    %{conn: conn, genre: genre, author: author, admin_token: admin_token, user_token: user_token}
  end

  describe "Public Access" do
    test "index returns list of books", %{conn: conn} do
      Books.create_book(%{"title" => "Public Book"})
      conn = get(conn, ~p"/api/v1/books")
      assert json_response(conn, 200)["data"] |> length() > 0
    end

    test "show returns book details", %{conn: conn, author: author} do
      {:ok, book} = Books.create_book(%{"title" => "Detailed Book", "author_ids" => [author.id]})
      conn = get(conn, ~p"/api/v1/books/#{book.id}")
      data = json_response(conn, 200)["data"]
      assert data["title"] == "Detailed Book"
      assert length(data["authors"]) == 1
    end
  end

  describe "Protected Access (Create/Update)" do
    test "admin can create book", %{conn: conn, admin_token: token, author: author} do
      conn = conn |> put_req_header("authorization", "Bearer #{token}")

      conn =
        post(conn, ~p"/api/v1/books", %{
          "book" => %{
            "title" => "Admin Book",
            "author_ids" => [author.id]
          }
        })

      assert json_response(conn, 201)["data"]["title"] == "Admin Book"
    end

    test "regular user cannot create book (403)", %{conn: conn, user_token: token} do
      conn = conn |> put_req_header("authorization", "Bearer #{token}")

      conn =
        post(conn, ~p"/api/v1/books", %{
          "book" => %{"title" => "Hacker Book"}
        })

      assert json_response(conn, 403)
    end

    test "unauthenticated user cannot create book (401)", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/books", %{
          "book" => %{"title" => "Anon Book"}
        })

      assert json_response(conn, 401)
    end

    test "admin can update book", %{conn: conn, admin_token: token} do
      {:ok, book} = Books.create_book(%{"title" => "Old Title"})
      conn = conn |> put_req_header("authorization", "Bearer #{token}")

      conn =
        put(conn, ~p"/api/v1/books/#{book.id}", %{
          "book" => %{"title" => "New Title"}
        })

      assert json_response(conn, 200)["data"]["title"] == "New Title"
    end
  end
end
