defmodule TheStoryVoyageApiWeb.ClubControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  alias TheStoryVoyageApi.Communities

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _} = TheStoryVoyageApi.Token.generate_token(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, user: user}
  end

  describe "create/2" do
    test "creates club when valid", %{conn: conn, user: _user} do
      conn =
        post(conn, ~p"/api/v1/clubs",
          club: %{name: "Test Club", description: "Desc", is_private: false}
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert Communities.get_club!(id)
    end
  end

  describe "join/2" do
    test "joins public club", %{conn: conn} do
      owner = user_fixture()

      {:ok, club} =
        Communities.create_club(owner, %{name: "Public", description: "desc", is_private: false})

      conn = post(conn, ~p"/api/v1/clubs/#{club.id}/join")
      assert json_response(conn, 201)["message"] == "Joined successfully request sent"
    end
  end

  describe "threads" do
    test "create_thread/2 posts thread", %{conn: conn, user: user} do
      # Create club and add user as member
      {:ok, club} =
        Communities.create_club(user, %{name: "My Club", description: "desc", is_private: false})

      # User is admin (member)

      conn =
        post(conn, ~p"/api/v1/clubs/#{club.id}/threads",
          thread: %{title: "Hello", content: "World", vote_count: 0}
        )

      assert %{"title" => "Hello"} = json_response(conn, 201)["data"]
    end

    test "vote_thread/2 votes", %{conn: conn, user: user} do
      {:ok, club} =
        Communities.create_club(user, %{name: "My Club", description: "desc", is_private: false})

      {:ok, thread} =
        Communities.create_thread(user, club.id, %{
          title: "Vote Me",
          content: "Pls",
          vote_count: 0
        })

      conn = post(conn, ~p"/api/v1/clubs/#{club.id}/threads/#{thread.id}/vote")
      assert json_response(conn, 200)["message"] == "Voted successfully"
    end
  end
end
