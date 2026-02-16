defmodule TheStoryVoyageApiWeb.BuddyReadControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures
  import TheStoryVoyageApi.CommunitiesFixtures

  alias TheStoryVoyageApi.Communities

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _} = TheStoryVoyageApi.Token.generate_token(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    {:ok, conn: conn, user: user}
  end

  describe "index" do
    test "lists visible buddy reads", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/buddy_reads")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create buddy_read" do
    test "renders buddy_read when data is valid", %{conn: conn} do
      book = book_fixture()

      conn =
        post(conn, ~p"/api/v1/buddy_reads",
          buddy_read: %{
            start_date: ~D[2026-03-01],
            book_id: book.id
          }
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert Communities.get_buddy_read!(id)
    end
  end

  describe "join buddy_read" do
    test "joins buddy read if allowed", %{conn: conn, user: user} do
      # Create another user and their buddy read
      creator = user_fixture()
      book = book_fixture()

      {:ok, br} =
        Communities.create_buddy_read(creator, %{start_date: ~D[2026-03-01], book_id: book.id})

      # Make them friends
      TheStoryVoyageApi.Repo.insert!(%TheStoryVoyageApi.Social.UserFollow{
        follower_id: user.id,
        followed_id: creator.id,
        is_friend: true
      })

      conn = post(conn, ~p"/api/v1/buddy_reads/#{br.id}/join")
      assert json_response(conn, 201)["message"] == "Joined buddy read successfully"
    end

    test "fails if not friend", %{conn: conn} do
      creator = user_fixture()
      book = book_fixture()

      {:ok, br} =
        Communities.create_buddy_read(creator, %{start_date: ~D[2026-03-01], book_id: book.id})

      conn = post(conn, ~p"/api/v1/buddy_reads/#{br.id}/join")
      assert json_response(conn, 403)
    end
  end
end
