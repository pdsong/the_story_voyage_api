defmodule TheStoryVoyageApiWeb.StatsControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _claims} = TheStoryVoyageApi.Token.generate_token(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, user: user}
  end

  describe "show" do
    test "returns user stats", %{conn: conn, user: user} do
      book = book_fixture(%{"pages" => 100})
      TheStoryVoyageApi.Accounts.track_book(user, book.id, %{status: "read", rating: 5})

      conn = get(conn, ~p"/api/v1/me/stats")
      data = json_response(conn, 200)["data"]

      assert data["read_count"] == 1
      assert data["total_pages_read"] == 100
      assert data["average_rating"] == 5.0
    end
  end
end
