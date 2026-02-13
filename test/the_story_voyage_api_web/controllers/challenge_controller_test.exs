defmodule TheStoryVoyageApiWeb.ChallengeControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.ChallengesFixtures
  import TheStoryVoyageApi.BooksFixtures

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _claims} = TheStoryVoyageApi.Token.generate_and_sign(%{"user_id" => user.id})
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, user: user}
  end

  describe "challenges" do
    test "GET /challenges lists available", %{conn: conn} do
      challenge_fixture()
      conn = get(conn, ~p"/api/v1/challenges")
      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "POST /challenges/:id/join", %{conn: conn} do
      challenge = challenge_fixture()
      conn = post(conn, ~p"/api/v1/challenges/#{challenge.id}/join")
      assert json_response(conn, 201)["data"]["status"] == "joined"
    end
  end
end
