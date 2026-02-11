defmodule TheStoryVoyageApiWeb.PasswordResetControllerTest do
  use TheStoryVoyageApiWeb.ConnCase
  import Swoosh.TestAssertions

  alias TheStoryVoyageApi.Accounts

  setup do
    {:ok, user} =
      Accounts.register_user(%{
        username: "reset_user",
        email: "reset@example.com",
        password: "password123"
      })

    %{user: user}
  end

  describe "POST /api/v1/auth/request_reset" do
    test "sends email when user exists", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/v1/auth/request_reset", %{"email" => user.email})
      assert json_response(conn, 202)

      assert_email_sent(fn email ->
        assert email.to == [{"", user.email}]
        assert email.subject == "Reset your password"
        assert email.text_body =~ "copying this token"
      end)
    end

    test "returns 202 even if email does not exist (security)", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/request_reset", %{"email" => "unknown@example.com"})
      assert json_response(conn, 202)
      assert_no_email_sent()
    end
  end

  describe "POST /api/v1/auth/reset_password" do
    setup %{user: user} do
      {:ok, user} = Accounts.create_reset_token(user)
      %{user: user, token: user.reset_password_token}
    end

    test "resets password with valid token", %{conn: conn, token: token} do
      conn =
        post(conn, ~p"/api/v1/auth/reset_password", %{
          "token" => token,
          "password" => "newpassword123"
        })

      assert json_response(conn, 200)

      # Verify password changed
      updated_user = Accounts.get_user_by_email("reset@example.com")
      assert Bcrypt.verify_pass("newpassword123", updated_user.password_hash)
      refute Bcrypt.verify_pass("password123", updated_user.password_hash)

      # Verify token cleared
      assert is_nil(updated_user.reset_password_token)
    end

    test "returns 404/422 with invalid token", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/auth/reset_password", %{
          "token" => "invalid_token",
          "password" => "newpassword123"
        })

      assert json_response(conn, 404)
    end

    test "returns 422 with short password", %{conn: conn, token: token} do
      conn =
        post(conn, ~p"/api/v1/auth/reset_password", %{
          "token" => token,
          "password" => "short"
        })

      assert %{"errors" => errors} = json_response(conn, 422)
      assert errors["password"]
    end
  end
end
