defmodule TheStoryVoyageApiWeb.AuthPlugTest do
  use TheStoryVoyageApiWeb.ConnCase
  alias TheStoryVoyageApiWeb.AuthPlug
  alias TheStoryVoyageApi.{Token, Accounts}

  setup do
    {:ok, user} =
      Accounts.register_user(%{
        username: "plug_user",
        email: "plug@example.com",
        password: "password123"
      })

    {:ok, token, _} = Token.generate_token(user)
    %{user: user, token: token}
  end

  test "assigns current_user when token is valid", %{conn: conn, user: user, token: token} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> AuthPlug.call(%{})

    assert conn.assigns.current_user.id == user.id
    refute conn.halted
  end

  test "halts with 401 when token is missing", %{conn: conn} do
    conn = AuthPlug.call(conn, %{})
    assert conn.status == 401
    assert conn.halted
  end

  test "halts with 401 when token is invalid", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer invalid.token.here")
      |> AuthPlug.call(%{})

    assert conn.status == 401
    assert conn.halted
  end
end
