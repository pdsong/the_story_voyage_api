defmodule TheStoryVoyageApi.Accounts.UserBookRemediationTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Accounts
  alias TheStoryVoyageApi.Books
  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  describe "recalculate_book_rating/1" do
    test "updates book average rating and count" do
      user1 = user_fixture()
      user2 = user_fixture()
      book = book_fixture()

      # User 1 rates 4.0
      Accounts.track_book(user1, book.id, %{status: "read", rating: 4.0})
      book = Books.get_book!(book.id)
      assert book.ratings_count == 1
      assert book.average_rating == 4.0

      # User 2 rates 5.0
      Accounts.track_book(user2, book.id, %{status: "read", rating: 5.0})
      book = Books.get_book!(book.id)
      assert book.ratings_count == 2
      assert book.average_rating == 4.5

      # User 1 changes rating to 2.0
      Accounts.track_book(user1, book.id, %{status: "read", rating: 2.0})
      book = Books.get_book!(book.id)
      # (2 + 5) / 2 = 3.5
      assert book.ratings_count == 2
      assert book.average_rating == 3.5

      # Test float precision (e.g. 4.25)
      user3 = user_fixture()
      Accounts.track_book(user3, book.id, %{status: "read", rating: 4.25})
      book = Books.get_book!(book.id)
      # (2.0 + 5.0 + 4.25) / 3 = 11.25 / 3 = 3.75
      assert book.ratings_count == 3
      assert book.average_rating == 3.75
    end

    test "handles untrack (delete)" do
      user = user_fixture()
      book = book_fixture()

      Accounts.track_book(user, book.id, %{status: "read", rating: 5.0})
      book = Books.get_book!(book.id)
      assert book.ratings_count == 1

      Accounts.untrack_book(user, book.id)
      book = Books.get_book!(book.id)
      assert book.ratings_count == 0
      assert book.average_rating == 0.0
    end

    test "handles review_contains_spoilers" do
      user = user_fixture()
      book = book_fixture()

      {:ok, ub} =
        Accounts.track_book(user, book.id, %{
          status: "read",
          rating: 5.0,
          review_contains_spoilers: true
        })

      assert ub.review_contains_spoilers == true

      saved_ub = Accounts.get_user_book(user, book.id)
      assert saved_ub.review_contains_spoilers == true
    end
  end
end
