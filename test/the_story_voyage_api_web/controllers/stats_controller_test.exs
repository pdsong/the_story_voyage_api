defmodule TheStoryVoyageApiWeb.StatsControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _claims} = TheStoryVoyageApi.Token.generate_and_sign(%{"user_id" => user.id})
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, user: user}
  end

  describe "stats endpoints" do
    test "GET /stats returns overview", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/stats")
      assert json_response(conn, 200)["data"]["read_count"] == 0
    end

    test "GET /stats/year/:year returns year stats", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/stats/year/2026")
      resp = json_response(conn, 200)["data"]
      assert resp["year"] == 2026
      assert resp["book_count"] == 0
      assert is_list(resp["monthly_timeline"])
    end

    test "GET /stats/genres returns distribution", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/stats/genres")
      assert json_response(conn, 200)["data"] == []
    end

    test "GET /stats/moods returns distribution", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/stats/moods")
      assert json_response(conn, 200)["data"] == []
    end
  end
end
