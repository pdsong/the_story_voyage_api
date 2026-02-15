defmodule TheStoryVoyageApiWeb.ActivityControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  alias TheStoryVoyageApi.Social

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _claims} = TheStoryVoyageApi.Token.generate_token(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, user: user}
  end

  describe "index" do
    test "lists activities from followed users", %{conn: conn, user: user} do
      # User follows another user
      other_user = user_fixture()
      Social.follow_user(user, other_user)

      # Other user creates activity
      book = book_fixture()
      Social.create_activity(other_user, "started_book", %{book_id: book.id})

      conn = get(conn, ~p"/api/v1/me/feed")
      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "does not list activities from non-followed users", %{conn: conn} do
      other_user = user_fixture()
      # No follow

      book = book_fixture()
      Social.create_activity(other_user, "started_book", %{book_id: book.id})

      conn = get(conn, ~p"/api/v1/me/feed")
      assert json_response(conn, 200)["data"] == []
    end
  end
end
