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
end
