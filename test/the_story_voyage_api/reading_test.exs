defmodule TheStoryVoyageApi.ReadingTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Reading
  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  describe "user_book_tags" do
    setup do
      user = user_fixture()
      book = book_fixture()

      {:ok, user_book} =
        TheStoryVoyageApi.Accounts.track_book(user, book.id, %{status: "reading"})

      %{user_book: user_book, user: user}
    end

    test "add_tag/2 adds a tag", %{user_book: user_book} do
      assert {:ok, tag} = Reading.add_tag(user_book, "summer-2025")
      assert tag.tag_name == "summer-2025"
    end

    test "add_tag/2 normalizes tag name", %{user_book: user_book} do
      assert {:ok, tag} = Reading.add_tag(user_book, "  Summer-2025  ")
      assert tag.tag_name == "summer-2025"
    end

    test "add_tag/2 prevents duplicates", %{user_book: user_book} do
      Reading.add_tag(user_book, "fav")
      assert {:error, changeset} = Reading.add_tag(user_book, "fav")
      # Unique constraint error might be on user_book_id or tag_name depending on index order/ecto
      errors = errors_on(changeset)
      assert "has already been taken" in (errors[:tag_name] || errors[:user_book_id])
    end

    test "remove_tag/2 removes a tag", %{user_book: user_book} do
      Reading.add_tag(user_book, "fav")
      assert {:ok, :deleted} = Reading.remove_tag(user_book, "fav")
      assert Reading.list_tags(user_book) == []
    end

    test "list_user_tags/1 returns unique tags for user", %{user: user, user_book: user_book} do
      Reading.add_tag(user_book, "fav")
      Reading.add_tag(user_book, "sci-fi")

      # Another book
      book2 = book_fixture()
      {:ok, user_book2} = TheStoryVoyageApi.Accounts.track_book(user, book2.id, %{status: "read"})
      Reading.add_tag(user_book2, "fav")

      tags = Reading.list_user_tags(user.id)
      assert tags == ["fav", "sci-fi"]
    end
  end
end
