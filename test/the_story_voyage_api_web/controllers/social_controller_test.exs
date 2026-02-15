defmodule TheStoryVoyageApiWeb.SocialControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  alias TheStoryVoyageApi.Social

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _claims} = TheStoryVoyageApi.Token.generate_and_sign(%{"user_id" => user.id})
    authed_conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, authed_conn: authed_conn, user: user}
  end

  describe "follows" do
    test "POST /users/:id/follow follows a user", %{authed_conn: conn, user: user} do
      other = user_fixture()
      conn = post(conn, ~p"/api/v1/users/#{other.id}/follow")
      assert json_response(conn, 201)["message"] == "Followed successfully"
      assert Social.following?(user.id, other.id)
    end

    test "DELETE /users/:id/follow unfollows", %{authed_conn: conn, user: user} do
      other = user_fixture()
      Social.follow_user(user, other)

      conn = delete(conn, ~p"/api/v1/users/#{other.id}/follow")
      assert response(conn, 204)
      refute Social.following?(user.id, other.id)
    end
  end

  describe "friend requests" do
    test "POST /users/:id/friend_request sends request", %{authed_conn: conn, user: user} do
      other = user_fixture()
      conn = post(conn, ~p"/api/v1/users/#{other.id}/friend_request")

      data = json_response(conn, 201)["data"]
      assert data["status"] == "pending"
      assert data["sender_id"] == user.id
    end

    test "PUT /friend_requests/:id/accept accepts request", %{conn: conn} do
      sender = user_fixture()
      receiver = user_fixture()
      {:ok, req} = Social.send_friend_request(sender, receiver)

      # Auth as receiver
      {:ok, token, _} = TheStoryVoyageApi.Token.generate_and_sign(%{"user_id" => receiver.id})
      authed_conn = put_req_header(conn, "authorization", "Bearer #{token}")

      conn = put(authed_conn, ~p"/api/v1/friend_requests/#{req.id}/accept")
      assert json_response(conn, 200)["message"] == "Friend request accepted"

      assert Social.following?(sender.id, receiver.id)
    end
  end
end
