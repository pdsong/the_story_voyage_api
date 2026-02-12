defmodule TheStoryVoyageApi.Accounts.StatsTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Accounts
  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  describe "get_user_stats/1" do
    test "returns correct statistics" do
      user = user_fixture()

      # 1. Read book with 300 pages, rated 5
      book1 = book_fixture(%{"pages" => 300})
      Accounts.track_book(user, book1.id, %{status: "read", rating: 5})

      # 2. Read book with 200 pages, rated 4
      book2 = book_fixture(%{"pages" => 200})
      Accounts.track_book(user, book2.id, %{status: "read", rating: 4})

      # 3. Reading book (pages don't count towards total read), not rated
      book3 = book_fixture(%{"pages" => 500})
      Accounts.track_book(user, book3.id, %{status: "reading"})

      # 4. Want to read book (no pages, no rating)
      book4 = book_fixture()
      Accounts.track_book(user, book4.id, %{status: "want_to_read"})

      stats = Accounts.get_user_stats(user.id)

      assert stats.read_count == 2
      assert stats.reading_count == 1
      assert stats.total_pages_read == 500
      assert stats.average_rating == 4.5
    end

    test "returns zeros for user with no activity" do
      user = user_fixture()
      stats = Accounts.get_user_stats(user.id)

      assert stats.read_count == 0
      assert stats.reading_count == 0
      assert stats.total_pages_read == 0
      assert stats.average_rating == 0.0
    end
  end
end
