defmodule TheStoryVoyageApiWeb.ReviewControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  setup do
    user = user_fixture()
    book = book_fixture()
    # Create a review
    TheStoryVoyageApi.Accounts.track_book(user, book.id, %{
      status: "read",
      rating: 5,
      review_title: "Great Book",
      review_content: "I loved it!"
    })

    %{conn: build_conn(), book: book, user: user}
  end

  describe "index" do
    test "lists reviews for a book", %{conn: conn, book: book} do
      conn = get(conn, ~p"/api/v1/books/#{book.id}/reviews")
      assert json_response(conn, 200)["data"] |> length() == 1

      first_review = json_response(conn, 200)["data"] |> hd()
      assert first_review["title"] == "Great Book"
      assert first_review["content"] == "I loved it!"
      assert first_review["user"]["username"]
    end

    test "does not list empty reviews", %{conn: conn} do
      user2 = user_fixture()
      book2 = book_fixture()
      # Track book without review content
      TheStoryVoyageApi.Accounts.track_book(user2, book2.id, %{
        status: "read",
        rating: 4
      })

      conn = get(conn, ~p"/api/v1/books/#{book2.id}/reviews")
      assert json_response(conn, 200)["data"] == []
    end
  end
end
