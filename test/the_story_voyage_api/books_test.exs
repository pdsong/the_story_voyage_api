defmodule TheStoryVoyageApi.BooksTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Books

  setup do
    # Create some genres and moods (already seeded, but fine to create for test)
    genre1 = Books.create_genre(%{name: "Fantasy", slug: "fantasy"}) |> elem(1)
    genre2 = Books.create_genre(%{name: "Sci-Fi", slug: "sci-fi"}) |> elem(1)
    mood1 = Books.create_mood(%{name: "Dark", slug: "dark"}) |> elem(1)
    author = Books.create_author(%{name: "Test Author"}) |> elem(1)

    %{genre1: genre1, genre2: genre2, mood1: mood1, author: author}
  end

  # Helper since we cannot rely on seeds in clean test DB unless we run seeds (which mix test setup usually does not reload if sandbox)
  # But my setup above creates them manually so we are good.

  describe "books" do
    test "create_book/1 with associations", %{genre1: g1, mood1: m1, author: a1} do
      attrs = %{
        "title" => "New Book",
        "author_ids" => [a1.id],
        "genre_ids" => [g1.id],
        "mood_ids" => [m1.id]
      }

      assert {:ok, book} = Books.create_book(attrs)
      book = Books.get_book(book.id)

      assert book.title == "New Book"
      assert length(book.authors) == 1
      assert hd(book.authors).id == a1.id
      assert length(book.genres) == 1
      assert hd(book.genres).id == g1.id
      assert length(book.moods) == 1
      assert hd(book.moods).id == m1.id
    end

    test "update_book/2 updates associations", %{genre1: g1, genre2: g2, author: a1} do
      {:ok, book} =
        Books.create_book(%{"title" => "Book", "author_ids" => [a1.id], "genre_ids" => [g1.id]})

      update_attrs = %{
        # Switch genre
        "genre_ids" => [g2.id]
      }

      assert {:ok, updated_book} = Books.update_book(book, update_attrs)
      book = Books.get_book(updated_book.id)

      assert length(book.genres) == 1
      assert hd(book.genres).id == g2.id
    end

    test "list_books/1 basic pagination" do
      for i <- 1..5, do: Books.create_book(%{"title" => "Book #{i}"})

      # Test limit
      page1 = Books.list_books(%{"limit" => 2, "offset" => 0})
      assert length(page1) == 2

      # Test offset
      page2 = Books.list_books(%{"limit" => 2, "offset" => 2})
      assert length(page2) == 2
      assert hd(page2).title != hd(page1).title
    end

    test "list_books/1 search and filter", %{genre1: g1, genre2: g2, mood1: m1} do
      {:ok, b1} =
        Books.create_book(%{
          "title" => "Elixir Guide",
          "genre_ids" => [g1.id],
          "mood_ids" => [m1.id]
        })

      {:ok, _b2} = Books.create_book(%{"title" => "Rust Guide", "genre_ids" => [g2.id]})
      {:ok, b3} = Books.create_book(%{"title" => "Advanced Elixir", "genre_ids" => [g1.id]})

      # Search by keyword
      assert [match] = Books.list_books(%{"q" => "Advanced"})
      assert match.id == b3.id

      # Search by kw (case insensitive)
      results = Books.list_books(%{"q" => "elixir"})
      assert length(results) == 2

      # Filter by genre
      results = Books.list_books(%{"genre_id" => g1.id})
      assert length(results) == 2
      assert Enum.all?(results, fn b -> b.id in [b1.id, b3.id] end)

      # Filter by mood
      assert [match] = Books.list_books(%{"mood_id" => m1.id})
      assert match.id == b1.id

      # Combined
      results = Books.list_books(%{"q" => "Elixir", "genre_id" => g1.id})
      assert length(results) == 2

      # Combined with mood
      assert [match] =
               Books.list_books(%{"q" => "Elixir", "genre_id" => g1.id, "mood_id" => m1.id})

      assert match.id == b1.id
    end
  end
end
