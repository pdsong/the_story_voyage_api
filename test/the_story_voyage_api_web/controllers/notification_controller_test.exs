defmodule TheStoryVoyageApiWeb.NotificationControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  alias TheStoryVoyageApi.Notifications

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _} = TheStoryVoyageApi.Token.generate_token(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, user: user}
  end

  describe "index" do
    test "lists notifications", %{conn: conn, user: user} do
      Notifications.create_notification(%{recipient_id: user.id, type: "new_follower"})

      conn = get(conn, ~p"/api/v1/me/notifications")
      assert length(json_response(conn, 200)["data"]) == 1
    end
  end

  describe "mark_read" do
    test "marks notification as read", %{conn: conn, user: user} do
      {:ok, n} = Notifications.create_notification(%{recipient_id: user.id, type: "new_follower"})

      conn = put(conn, ~p"/api/v1/me/notifications/#{n.id}/read")
      assert json_response(conn, 200)["data"]["read_at"]
    end
  end

  describe "mark_all_read" do
    test "marks all as read", %{conn: conn, user: user} do
      Notifications.create_notification(%{recipient_id: user.id, type: "new_follower"})

      conn = put(conn, ~p"/api/v1/me/notifications/read-all")
      assert response(conn, 204)
      assert Notifications.unread_count(user.id) == 0
    end
  end
end
