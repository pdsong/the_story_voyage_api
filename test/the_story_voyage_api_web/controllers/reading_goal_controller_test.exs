defmodule TheStoryVoyageApiWeb.ReadingGoalControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _claims} = TheStoryVoyageApi.Token.generate_and_sign(%{"user_id" => user.id})
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, user: user}
  end

  describe "reading goals" do
    test "POST /reading_goals creates goal", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/reading_goals", reading_goal: %{year: 2026, target: 50})
      assert %{"id" => _id} = json_response(conn, 201)["data"]
    end

    test "GET /reading_goals lists goals", %{conn: conn} do
      post(conn, ~p"/api/v1/reading_goals", reading_goal: %{year: 2026, target: 50})
      conn = get(conn, ~p"/api/v1/reading_goals")
      assert length(json_response(conn, 200)["data"]) == 1
    end
  end
end
