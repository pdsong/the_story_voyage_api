defmodule TheStoryVoyageApi.TokenTest do
  use ExUnit.Case, async: true
  alias TheStoryVoyageApi.Token

  test "generates and verifies token" do
    user = %{id: 1, role: "user"}
    {:ok, token, _claims} = Token.generate_token(user)

    assert is_binary(token)
    assert {:ok, claims} = Token.verify_token(token)
    assert claims["user_id"] == 1
    assert claims["role"] == "user"
  end

  test "verifies valid role" do
    user = %{id: 2, role: "admin"}
    {:ok, token, _} = Token.generate_token(user)
    assert {:ok, claims} = Token.verify_token(token)
    assert claims["role"] == "admin"
  end
end
