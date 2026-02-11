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
      assert Bcrypt.verify_pass("password123", user.password_hash)
    end
  end

  describe "POST /api/v1/auth/login" do
    setup do
      {:ok, user} = Accounts.register_user(@valid_user)
      %{user: user}
    end

    test "returns token and user with valid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/auth/login", %{
          "email" => @valid_user["email"],
          "password" => @valid_user["password"]
        })

      assert %{
               "token" => token,
               "user" => %{
                 "email" => "test@example.com",
                 "username" => "testuser"
               }
             } = json_response(conn, 200)

      assert is_binary(token)
    end

    test "returns 401 with invalid password", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/auth/login", %{
          "email" => @valid_user["email"],
          "password" => "wrongpass"
        })

      assert json_response(conn, 401)
    end

    test "returns 401 with non-existent email", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/auth/login", %{
          "email" => "nobody@example.com",
          "password" => "password123"
        })

      assert json_response(conn, 401)
    end
  end
end
