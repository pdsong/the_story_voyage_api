defmodule TheStoryVoyageApi.BooksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheStoryVoyageApi.Books` context.
  """
  alias TheStoryVoyageApi.Books

  def book_fixture(attrs \\ %{}) do
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
end
