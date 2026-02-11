defmodule TheStoryVoyageApi.Accounts.ResetTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Accounts

  setup do
    {:ok, user} =
      Accounts.register_user(%{
        username: "reset_unit",
        email: "unit@example.com",
        password: "password123"
      })

    %{user: user}
  end

  test "create_reset_token/1 generates token and sets timestamp", %{user: user} do
    {:ok, updated_user} = Accounts.create_reset_token(user)

    assert updated_user.reset_password_token
    assert updated_user.reset_password_sent_at
    # Ensure token is roughly 32 bytes encoded (length > 30)
    assert String.length(updated_user.reset_password_token) > 30
  end

  test "get_user_by_reset_token/1 finds user", %{user: user} do
    {:ok, updated_user} = Accounts.create_reset_token(user)
    found_user = Accounts.get_user_by_reset_token(updated_user.reset_password_token)

    assert found_user.id == user.id
  end

  test "reset_password/2 updates password and clears token", %{user: user} do
    {:ok, user_with_token} = Accounts.create_reset_token(user)

    {:ok, final_user} =
      Accounts.reset_password(user_with_token, %{password: "newpassword123"})

    assert Bcrypt.verify_pass("newpassword123", final_user.password_hash)
    refute final_user.reset_password_token
    refute final_user.reset_password_sent_at
  end
end
