defmodule TheStoryVoyageApi.BooksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheStoryVoyageApi.Books` context.
  """
  alias TheStoryVoyageApi.Books

  def book_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{})

    # Normalize keys to strings if they are atoms
    attrs =
      for {k, v} <- attrs, into: %{}, do: {to_string(k), v}

    {:ok, book} =
      attrs
      |> Enum.into(%{
        "title" => "Some Book Title #{System.unique_integer()}",
        "description" => "some description"
      })
      |> Books.create_book()

    book
  end

  def genre_fixture(attrs \\ %{}) do
    {:ok, genre} =
      attrs
      |> Enum.into(%{
        "name" => "Some Genre #{System.unique_integer()}",
        "slug" => "some-genre-#{System.unique_integer()}"
      })
      |> Books.create_genre()

    genre
  end

  def author_fixture(attrs \\ %{}) do
    {:ok, author} =
      attrs
      |> Enum.into(%{
        "name" => "Some Author #{System.unique_integer()}"
      })
      |> Books.create_author()

    author
  end

  def mood_fixture(attrs \\ %{}) do
    {:ok, mood} =
      attrs
      |> Enum.into(%{
        "name" => "Some Mood #{System.unique_integer()}",
        "slug" => "some-mood-#{System.unique_integer()}"
      })
      |> Books.create_mood()

    mood
  end
end
