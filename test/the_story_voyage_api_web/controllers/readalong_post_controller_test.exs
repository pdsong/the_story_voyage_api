defmodule TheStoryVoyageApiWeb.ReadalongPostControllerTest do
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

  describe "create post" do
    test "creates post when section is unlocked", %{conn: conn, user: _user} do
      owner = TheStoryVoyageApi.AccountsFixtures.user_fixture()
      book = book_fixture()
      past_date = DateTime.add(DateTime.utc_now(), -3600, :second)

      {:ok, readalong} =
        Communities.create_readalong(owner, %{
          title: "Unlocked Event",
          start_date: ~D[2026-04-01],
          book_id: book.id,
          sections: [%{title: "Unlocked", unlock_date: past_date}]
        })

      section = Communities.get_readalong!(readalong.id).sections |> hd()

      conn =
        post(conn, ~p"/api/v1/readalong_sections/#{section.id}/posts",
          post: %{content: "Hello discussion"}
        )

      assert %{"id" => _id} = json_response(conn, 201)["data"]
    end

    test "fails with 423 Locked when section is locked", %{conn: conn, user: _user} do
      owner = TheStoryVoyageApi.AccountsFixtures.user_fixture()
      book = book_fixture()
      future_date = DateTime.add(DateTime.utc_now(), 3600, :second)

      {:ok, readalong} =
        Communities.create_readalong(owner, %{
          title: "Locked Event",
          start_date: ~D[2026-04-01],
          book_id: book.id,
          sections: [%{title: "Locked", unlock_date: future_date}]
        })

      section = Communities.get_readalong!(readalong.id).sections |> hd()

      conn =
        post(conn, ~p"/api/v1/readalong_sections/#{section.id}/posts",
          post: %{content: "Spoiler!"}
        )

      assert json_response(conn, 423)["errors"]["detail"] =~ "locked"
    end
  end
end
