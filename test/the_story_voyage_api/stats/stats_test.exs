defmodule TheStoryVoyageApi.Stats.StatsTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Stats
  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  describe "stats extensions" do
    setup do
      user = user_fixture()
      book1 = book_fixture(%{"pages" => 100})
      book2 = book_fixture(%{"pages" => 200})

      # Helper to create read book with specific date
      create_read_book = fn user, book, date ->
        timestamp = DateTime.new!(date, ~T[12:00:00])

        # We need to insert UserBook directly to control updated_at/inserted_at
        %TheStoryVoyageApi.Accounts.UserBook{}
        |> Ecto.Changeset.change(%{
          user_id: user.id,
          book_id: book.id,
          status: "read",
          rating: 5.0,
          inserted_at: timestamp,
          updated_at: timestamp
        })
        |> TheStoryVoyageApi.Repo.insert!()
      end

      %{user: user, book1: book1, book2: book2, create_read_book: create_read_book}
    end

    test "get_comparison/3 returns correct diff", %{
      user: user,
      book1: book1,
      book2: book2,
      create_read_book: create_read_book
    } do
      # Period 1: Jan 2025
      create_read_book.(user, book1, ~D[2025-01-15])

      # Period 2: Feb 2025
      create_read_book.(user, book2, ~D[2025-02-15])

      p1 = %{start_date: ~U[2025-01-01 00:00:00Z], end_date: ~U[2025-01-31 23:59:59Z]}
      p2 = %{start_date: ~U[2025-02-01 00:00:00Z], end_date: ~U[2025-02-28 23:59:59Z]}

      stats = Stats.get_comparison(user.id, p1, p2)

      assert stats.period1.book_count == 1
      assert stats.period1.page_count == 100
      assert stats.period2.book_count == 1
      assert stats.period2.page_count == 200
      # 100 - 200
      assert stats.diff.page_count == -100
    end

    test "get_heatmap_data/2 returns daily counts", %{
      user: user,
      book1: book1,
      create_read_book: create_read_book
    } do
      create_read_book.(user, book1, ~D[2025-01-01])

      heatmap = Stats.get_heatmap_data(user.id, 2025)
      assert length(heatmap) == 1
      assert hd(heatmap) == %{date: ~D[2025-01-01], count: 1}
    end

    test "get_wrap_up/3 aggregations", %{
      user: user,
      book1: book1,
      create_read_book: create_read_book
    } do
      create_read_book.(user, book1, ~D[2025-01-01])

      wrap_up = Stats.get_wrap_up(user.id, :month, "2025-01")

      assert wrap_up.total_books == 1
      assert wrap_up.total_pages == 100
    end
  end
end
