defmodule TheStoryVoyageApi.Accounts.UserBookTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Accounts
  alias TheStoryVoyageApi.Accounts.UserBook
  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  describe "user_books" do
    @valid_attrs %{status: "reading", rating: 4, notes: "Good start"}
    @update_attrs %{status: "read", rating: 5, notes: "Loved it"}
    @invalid_attrs %{status: "invalid_status"}

    test "track_book/3 creates a user_book with valid data" do
      user = user_fixture()
      book = book_fixture()

      assert {:ok, %UserBook{} = ub} = Accounts.track_book(user, book.id, @valid_attrs)
      assert ub.status == "reading"
      assert ub.rating == 4
      assert ub.user_id == user.id
      assert ub.book_id == book.id
    end

    test "track_book/3 updates existing user_book" do
      user = user_fixture()
      book = book_fixture()
      {:ok, _} = Accounts.track_book(user, book.id, @valid_attrs)

      assert {:ok, %UserBook{} = ub} = Accounts.track_book(user, book.id, @update_attrs)
      assert ub.status == "read"
      assert ub.rating == 5
    end

    test "track_book/3 with invalid data returns error changeset" do
      user = user_fixture()
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.track_book(user, book.id, @invalid_attrs)
    end

    test "untrack_book/2 deletes the user_book" do
      user = user_fixture()
      book = book_fixture()
      {:ok, _} = Accounts.track_book(user, book.id, @valid_attrs)

      assert {:ok, %UserBook{}} = Accounts.untrack_book(user, book.id)
      assert nil == Accounts.get_user_book(user, book.id)
    end

    test "list_user_books/2 returns user's books" do
      user = user_fixture()
      book1 = book_fixture()
      book2 = book_fixture()

      Accounts.track_book(user, book1.id, %{status: "reading"})
      Accounts.track_book(user, book2.id, %{status: "read"})

      books = Accounts.list_user_books(user)
      assert length(books) == 2
    end

    test "list_user_books/2 filters by status" do
      user = user_fixture()
      book1 = book_fixture()
      book2 = book_fixture()

      Accounts.track_book(user, book1.id, %{status: "reading"})
      Accounts.track_book(user, book2.id, %{status: "read"})

      books = Accounts.list_user_books(user, %{"status" => "reading"})
      assert length(books) == 1
      assert hd(books).book_id == book1.id
    end
  end
end
