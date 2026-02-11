defmodule TheStoryVoyageApi.Books.BookTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Books.{Book, Genre, Mood, ContentWarning}
  alias TheStoryVoyageApi.Repo

  describe "Book schema" do
    test "changeset with valid title" do
      changeset = Book.changeset(%Book{}, %{title: "Programming Elixir"})
      assert changeset.valid?
    end

    test "changeset requires title" do
      changeset = Book.changeset(%Book{}, %{})
      refute changeset.valid?
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "changeset validates pace inclusion" do
      changeset = Book.changeset(%Book{}, %{title: "Test", pace: "invalid"})
      refute changeset.valid?
    end

    test "changeset validates rating range" do
      changeset = Book.changeset(%Book{}, %{title: "Test", average_rating: 6.0})
      refute changeset.valid?
    end
  end

  describe "Genre schema" do
    test "changeset requires name and slug" do
      changeset = Genre.changeset(%Genre{}, %{})
      refute changeset.valid?
    end

    test "changeset with valid data" do
      changeset = Genre.changeset(%Genre{}, %{name: "Elixir", slug: "elixir"})
      assert changeset.valid?
    end
  end

  describe "Mood schema" do
    test "changeset requires name and slug" do
      changeset = Mood.changeset(%Mood{}, %{})
      refute changeset.valid?
    end

    test "changeset with valid data" do
      changeset = Mood.changeset(%Mood{}, %{name: "Challenging", slug: "challenging"})
      assert changeset.valid?
    end
  end

  describe "ContentWarning schema" do
    test "changeset requires name and slug" do
      changeset = ContentWarning.changeset(%ContentWarning{}, %{})
      refute changeset.valid?
    end

    test "changeset with valid data" do
      changeset =
        ContentWarning.changeset(%ContentWarning{}, %{
          name: "Violence",
          slug: "violence",
          category: "violence"
        })

      assert changeset.valid?
    end
  end
end
