defmodule TheStoryVoyageApiWeb.AuthControllerTest do
  use TheStoryVoyageApiWeb.ConnCase

  alias TheStoryVoyageApi.Accounts

  @valid_user %{
    "username" => "testuser",
    "email" => "test@example.com",
    "password" => "password123"
  }

  describe "POST /api/v1/auth/register" do
    test "creates user with valid params", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/register", %{"user" => @valid_user})

      assert %{
               "user" => %{
                 "id" => _id,
                 "username" => "testuser",
                 "email" => "test@example.com",
                 "role" => "user"
               }
             } = json_response(conn, 201)
    end

    test "returns 422 for duplicate email", %{conn: conn} do
      post(conn, ~p"/api/v1/auth/register", %{"user" => @valid_user})
      conn = post(conn, ~p"/api/v1/auth/register", %{"user" => @valid_user})

      assert %{"errors" => errors} = json_response(conn, 422)
      assert errors["email"]
    end

    test "returns 422 for duplicate username", %{conn: conn} do
      post(conn, ~p"/api/v1/auth/register", %{"user" => @valid_user})

      conn =
        post(conn, ~p"/api/v1/auth/register", %{
          "user" => %{@valid_user | "email" => "other@example.com"}
        })

      assert %{"errors" => errors} = json_response(conn, 422)
      assert errors["username"]
    end

    test "returns 422 for missing fields", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/register", %{"user" => %{}})

      assert %{"errors" => errors} = json_response(conn, 422)
      assert errors["username"]
      assert errors["email"]
      assert errors["password"]
    end

    test "returns 422 for short password", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/auth/register", %{
          "user" => %{@valid_user | "password" => "short"}
        })

      assert %{"errors" => errors} = json_response(conn, 422)
      assert errors["password"]
    end

    test "returns 422 for invalid email", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/auth/register", %{
          "user" => %{@valid_user | "email" => "bad-email"}
        })

      assert %{"errors" => errors} = json_response(conn, 422)
      assert errors["email"]
    end

    test "returns 422 when user param is missing", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/register", %{})

      assert %{"errors" => _} = json_response(conn, 422)
    end

    test "password is hashed in database", %{conn: conn} do
      post(conn, ~p"/api/v1/auth/register", %{"user" => @valid_user})

      user = Accounts.get_user_by_email("test@example.com")
      assert user
      refute user.password_hash == "password123"
      assert Bcrypt.verify_pass("password123", user.password_hash)
    end
  end
end
