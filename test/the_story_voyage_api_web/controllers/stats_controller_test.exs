defmodule TheStoryVoyageApiWeb.StatsControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _} = TheStoryVoyageApi.Token.generate_token(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, user: user}
  end

  describe "comparison" do
    test "returns comparison data", %{conn: conn} do
      params = %{
        "from1" => "2025-01-01",
        "to1" => "2025-01-31",
        "from2" => "2025-02-01",
        "to2" => "2025-02-28"
      }

      conn = get(conn, ~p"/api/v1/stats/compare", params)
      assert json_response(conn, 200)["data"]["diff"]
    end
  end

  describe "heatmap" do
    test "returns heatmap array", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/stats/heatmap", year: 2025)
      assert is_list(json_response(conn, 200)["data"])
    end
  end

  describe "wrap_up" do
    test "returns wrap up summary", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/stats/wrap-up", type: "year", value: "2025")
      assert json_response(conn, 200)["data"]["total_books"]
    end

    test "returns 400 for invalid type", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/stats/wrap-up", type: "invalid", value: "2025")
      assert response(conn, 400)
    end
  end

  describe "year_stats" do
    test "returns year stats", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/stats/year/2025")
      assert json_response(conn, 200)["data"]["year"] == 2025
    end

    test "returns comparison when requested", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/stats/year/2025", compare: "true")
      data = json_response(conn, 200)["data"]
      # Current year
      assert data["period1"]
      # Previous year
      assert data["period2"]
    end
  end
end
