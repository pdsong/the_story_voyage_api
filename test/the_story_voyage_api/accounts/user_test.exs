defmodule TheStoryVoyageApi.Accounts.UserTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Accounts
  alias TheStoryVoyageApi.Accounts.User

  @valid_attrs %{
    username: "elixir_dev",
    email: "dev@example.com",
    password: "password123"
  }

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
    test "hashes password with bcrypt" do
      changeset = User.registration_changeset(%User{}, @valid_attrs)

      assert changeset.valid?
      hash = Ecto.Changeset.get_change(changeset, :password_hash)
      assert hash
      assert String.starts_with?(hash, "$2b$")
      refute Ecto.Changeset.get_change(changeset, :password)
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

  describe "Accounts.register_user/1" do
    test "creates user with valid params" do
      assert {:ok, user} = Accounts.register_user(@valid_attrs)
      assert user.username == "elixir_dev"
      assert user.email == "dev@example.com"
      assert user.password_hash
      assert String.starts_with?(user.password_hash, "$2b$")
      assert user.role == "user"
    end

    test "rejects duplicate email" do
      assert {:ok, _} = Accounts.register_user(@valid_attrs)
      assert {:error, changeset} = Accounts.register_user(@valid_attrs)
      assert %{email: _} = errors_on(changeset)
    end

    test "rejects duplicate username" do
      assert {:ok, _} = Accounts.register_user(@valid_attrs)

      assert {:error, changeset} =
               Accounts.register_user(%{@valid_attrs | email: "other@example.com"})

      assert %{username: _} = errors_on(changeset)
    end

    test "password is not stored in plain text" do
      assert {:ok, user} = Accounts.register_user(@valid_attrs)
      refute user.password_hash == "password123"
      assert Bcrypt.verify_pass("password123", user.password_hash)
    end

    test "rejects invalid email format" do
      assert {:error, changeset} =
               Accounts.register_user(%{@valid_attrs | email: "bad-email"})

      assert %{email: _} = errors_on(changeset)
    end

    test "rejects short password" do
      assert {:error, changeset} =
               Accounts.register_user(%{@valid_attrs | password: "short"})

      assert %{password: _} = errors_on(changeset)
    end
  end
end
