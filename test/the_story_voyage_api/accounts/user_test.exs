defmodule TheStoryVoyageApi.Accounts.UserTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Accounts.User

  describe "User changeset" do
    test "valid changeset" do
      changeset =
        User.changeset(%User{}, %{
          username: "elixir_dev",
          email: "dev@example.com",
          password_hash: "hashed_password"
        })

      assert changeset.valid?
    end

    test "requires username, email, and password_hash" do
      changeset = User.changeset(%User{}, %{})
      refute changeset.valid?

      errors = errors_on(changeset)
      assert errors[:username]
      assert errors[:email]
      assert errors[:password_hash]
    end

    test "validates username length min 3" do
      changeset =
        User.changeset(%User{}, %{
          username: "ab",
          email: "dev@example.com",
          password_hash: "hashed"
        })

      refute changeset.valid?
      assert %{username: ["should be at least 3 character(s)"]} = errors_on(changeset)
    end

    test "validates email format" do
      changeset =
        User.changeset(%User{}, %{
          username: "abc",
          email: "not_an_email",
          password_hash: "hashed"
        })

      refute changeset.valid?
      assert %{email: ["must be a valid email address"]} = errors_on(changeset)
    end

    test "validates privacy_level inclusion" do
      changeset =
        User.changeset(%User{}, %{
          username: "abc",
          email: "dev@test.com",
          password_hash: "hashed",
          privacy_level: "invalid"
        })

      refute changeset.valid?
    end

    test "validates role inclusion" do
      changeset =
        User.changeset(%User{}, %{
          username: "abc",
          email: "dev@test.com",
          password_hash: "hashed",
          role: "superadmin"
        })

      refute changeset.valid?
    end
  end

  describe "User registration changeset" do
    test "hashes password" do
      changeset =
        User.registration_changeset(%User{}, %{
          username: "elixir_dev",
          email: "dev@example.com",
          password: "password123"
        })

      assert changeset.valid?
      assert get_change(changeset, :password_hash)
      refute get_change(changeset, :password)
    end

    test "validates password min 8 chars" do
      changeset =
        User.registration_changeset(%User{}, %{
          username: "elixir_dev",
          email: "dev@example.com",
          password: "short"
        })

      refute changeset.valid?
      assert %{password: ["should be at least 8 character(s)"]} = errors_on(changeset)
    end
  end
end
