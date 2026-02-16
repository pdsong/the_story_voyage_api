defmodule TheStoryVoyageApiWeb.RecommendationControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.BooksFixtures
  alias TheStoryVoyageApi.Books
  import Ecto.Query

  setup %{conn: conn} do
    user = TheStoryVoyageApi.AccountsFixtures.user_fixture()
    {:ok, conn: put_req_header(conn, "authorization", "Bearer " <> token(user)), user: user}
  end

  defp token(user) do
    {:ok, token, _} = TheStoryVoyageApi.Token.generate_and_sign(%{"user_id" => user.id})
    token
  end

  describe "index" do
    test "returns top rated books for new users (cold start)", %{conn: conn} do
      # Create some books with different ratings
      book1 =
        book_fixture(%{"title" => "Top Rated", "average_rating" => 5.0, "ratings_count" => 10})

      _book2 =
        book_fixture(%{"title" => "Low Rated", "average_rating" => 2.0, "ratings_count" => 10})

      conn = get(conn, ~p"/api/v1/recommendations")
      data = json_response(conn, 200)["data"]

      assert length(data) > 0
      ids = Enum.map(data, & &1["id"])
      assert book1.id in ids
    end

    test "returns similar books based on history", %{conn: conn, user: user} do
      # Setup: User likes Genre A
      genre_a = genre_fixture()
      book_liked = book_fixture(%{"title" => "Liked Book", "genre_ids" => [genre_a.id]})

      # User rates it 5 stars manually in DB
      timestamp = DateTime.utc_now() |> DateTime.truncate(:second)

      TheStoryVoyageApi.Repo.insert!(%TheStoryVoyageApi.Accounts.UserBook{
        user_id: user.id,
        book_id: book_liked.id,
        status: "read",
        rating: 5.0,
        inserted_at: timestamp,
        updated_at: timestamp
      })

      # Create another book in same genre
      book_rec = book_fixture(%{"title" => "Recommended Book", "genre_ids" => [genre_a.id]})
      # Create random book
      genre_b = genre_fixture()
      _book_random = book_fixture(%{"title" => "Random Book", "genre_ids" => [genre_b.id]})

      conn = get(conn, ~p"/api/v1/recommendations")
      data = json_response(conn, 200)["data"]

      ids = Enum.map(data, & &1["id"])
      assert book_rec.id in ids
      # Should be excluded as already read
      assert book_liked.id not in ids
    end
  end
end
