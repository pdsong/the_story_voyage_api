defmodule TheStoryVoyageApiWeb.ReadalongControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.CommunitiesFixtures
  import TheStoryVoyageApi.BooksFixtures

  alias TheStoryVoyageApi.Communities

  setup %{conn: conn} do
    user = TheStoryVoyageApi.AccountsFixtures.user_fixture()
    {:ok, conn: put_req_header(conn, "authorization", "Bearer " <> token(user)), user: user}
  end

  defp token(user) do
    {:ok, token, _} = TheStoryVoyageApi.Token.generate_and_sign(%{"user_id" => user.id})
    token
  end

  describe "index" do
    test "lists all readalongs", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/readalongs")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create readalong" do
    test "renders readalong when data is valid", %{conn: conn} do
      book = book_fixture()

      create_attrs = %{
        title: "some title",
        description: "some description",
        start_date: ~D[2026-04-01],
        book_id: book.id,
        sections: [
          %{
            title: "Week 1",
            start_chapter: 1,
            end_chapter: 5,
            unlock_date: ~U[2026-04-01 10:00:00Z]
          }
        ]
      }

      conn = post(conn, ~p"/api/v1/readalongs", readalong: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/v1/readalongs/#{id}")
      data = json_response(conn, 200)["data"]
      assert data["id"] == id
      assert data["title"] == "some title"
      assert length(data["sections"]) == 1
    end
  end

  describe "join readalong" do
    test "joins successfully", %{conn: conn, user: user} do
      # Create readalong by another user
      other_user = TheStoryVoyageApi.AccountsFixtures.user_fixture()
      book = book_fixture()

      {:ok, readalong} =
        Communities.create_readalong(other_user, %{
          title: "Event",
          start_date: ~D[2026-05-01],
          book_id: book.id
        })

      conn = post(conn, ~p"/api/v1/readalongs/#{readalong.id}/join")
      assert json_response(conn, 201)["data"]["message"] == "Joined successfully"

      assert Communities.is_readalong_participant?(user.id, readalong.id)
    end
  end
end
