defmodule TheStoryVoyageApiWeb.UserControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  alias TheStoryVoyageApi.Accounts

  setup %{conn: conn} do
    user =
      user_fixture(%{display_name: "Original Name", bio: "Original Bio", privacy_level: "public"})

    {:ok, token, _claims} = TheStoryVoyageApi.Token.generate_and_sign(%{"user_id" => user.id})
    authed_conn = put_req_header(conn, "authorization", "Bearer #{token}")
    %{conn: conn, authed_conn: authed_conn, user: user}
  end

  describe "me" do
    test "GET /users/me returns current user profile", %{authed_conn: conn, user: user} do
      conn = get(conn, ~p"/api/v1/users/me")
      assert json_response(conn, 200)["data"]["id"] == user.id
      # Private data visible
      assert json_response(conn, 200)["data"]["email"] == user.email
    end

    test "PUT /users/me updates profile fields", %{authed_conn: conn} do
      update_attrs = %{
        "display_name" => "Updated Name",
        "bio" => "New Bio",
        "location" => "New City"
      }

      conn = put(conn, ~p"/api/v1/users/me", user: update_attrs)

      data = json_response(conn, 200)["data"]
      assert data["display_name"] == "Updated Name"
      assert data["bio"] == "New Bio"
      assert data["location"] == "New City"
    end

    test "PUT /users/me ignores restricted fields like role", %{authed_conn: conn} do
      conn = put(conn, ~p"/api/v1/users/me", user: %{"role" => "admin"})
      data = json_response(conn, 200)["data"]
      # Should not change
      assert data["role"] == "user"
    end
  end

  describe "public profile" do
    test "GET /users/:username returns public info", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/v1/users/#{user.username}")
      data = json_response(conn, 200)["data"]
      assert data["username"] == user.username
      # Private data hidden
      refute Map.has_key?(data, "email")
    end

    test "GET /users/:username/books returns books", %{conn: conn, user: user} do
      book = book_fixture()
      {:ok, _ub} = Accounts.track_book(user, book.id, %{status: "read"})

      conn = get(conn, ~p"/api/v1/users/#{user.username}/books")
      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "GET /users/:username/books respects privacy", %{conn: conn} do
      private_user =
        user_fixture(%{username: "private_user", email: "p@ex.com"})

      {:ok, private_user} =
        Accounts.update_user_profile(private_user, %{privacy_level: "private"})

      conn = get(conn, ~p"/api/v1/users/#{private_user.username}/books")
      # Expect forbidden for unauthenticated/other user accessing private bookshelf
      # Controller logic: if user.privacy_level == "private" and not is_me -> 403
      assert json_response(conn, 403)
    end
  end
end
