defmodule TheStoryVoyageApiWeb.BookContentWarningControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.BooksFixtures
  alias TheStoryVoyageApi.Books

  setup %{conn: conn} do
    user = TheStoryVoyageApi.AccountsFixtures.user_fixture()
    {:ok, conn: put_req_header(conn, "authorization", "Bearer " <> token(user)), user: user}
  end

  defp token(user) do
    {:ok, token, _} = TheStoryVoyageApi.Token.generate_and_sign(%{"user_id" => user.id})
    token
  end

  describe "create content warning" do
    test "adds warning to book", %{conn: conn} do
      book = book_fixture()
      # Create a content warning manually since we might not have seeds running in test env
      {:ok, cw} =
        Books.create_content_warning(%{
          name: "Test Warning",
          slug: "test-warning",
          category: "test"
        })

      conn =
        post(conn, ~p"/api/v1/books/#{book.id}/content_warnings", %{content_warning_id: cw.id})

      assert json_response(conn, 201)["data"]["message"] == "Content warning added successfully"

      # Verify it shows up in book details
      conn = get(conn, ~p"/api/v1/books/#{book.id}")
      data = json_response(conn, 200)["data"]
      assert Enum.any?(data["content_warnings"], fn w -> w["id"] == cw.id end)
    end
  end
end
