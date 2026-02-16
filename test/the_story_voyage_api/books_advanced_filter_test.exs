defmodule TheStoryVoyageApi.BooksAdvancedFilterTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Books
  import TheStoryVoyageApi.BooksFixtures

  describe "list_books/1 with advanced filters" do
    setup do
      author = author_fixture()

      book1 =
        book_fixture(%{
          title: "Book One",
          average_rating: 4.5,
          ratings_count: 100,
          pages: 350,
          first_published: ~D[2020-01-01],
          author_ids: [author.id]
        })

      book2 =
        book_fixture(%{
          title: "Book Two",
          average_rating: 3.5,
          ratings_count: 50,
          pages: 200,
          first_published: ~D[2010-06-15]
        })

      book3 =
        book_fixture(%{
          title: "Book Three",
          average_rating: 4.8,
          ratings_count: 10,
          pages: 800,
          first_published: ~D[2025-01-01]
        })

      %{books: [book1, book2, book3], author: author}
    end

    test "filter by min_rating", %{books: [b1, _b2, b3]} do
      books = Books.list_books(%{"min_rating" => 4.0})
      ids = Enum.map(books, & &1.id)
      assert b1.id in ids
      assert b3.id in ids
      assert length(ids) == 2
    end

    test "filter by pages (min/max)", %{books: [b1, b2, _b3]} do
      books = Books.list_books(%{"min_pages" => 200, "max_pages" => 400})
      ids = Enum.map(books, & &1.id)
      assert b1.id in ids
      assert b2.id in ids
      assert length(ids) == 2
    end

    test "filter by publication year", %{books: [_b1, b2, _b3]} do
      books =
        Books.list_books(%{"published_year_start" => "2009", "published_year_end" => "2011"})

      ids = Enum.map(books, & &1.id)
      assert b2.id in ids
      assert length(ids) == 1
    end

    test "filter by author", %{books: [b1, _b2, _b3], author: author} do
      books = Books.list_books(%{"author_id" => author.id})
      ids = Enum.map(books, & &1.id)
      assert b1.id in ids
      assert length(ids) == 1
    end

    test "sort by newest", %{books: [b1, b2, b3]} do
      books = Books.list_books(%{"sort_by" => "newest"})
      assert hd(books).id == b3.id
      assert List.last(books).id == b2.id
    end

    test "sort by oldest", %{books: [b1, b2, b3]} do
      books = Books.list_books(%{"sort_by" => "oldest"})
      assert hd(books).id == b2.id
      assert List.last(books).id == b3.id
    end

    test "sort by top_rated", %{books: [b1, _b2, b3]} do
      books = Books.list_books(%{"sort_by" => "top_rated"})
      # b3: 4.8, b1: 4.5, b2: 3.5
      assert Enum.at(books, 0).id == b3.id
      assert Enum.at(books, 1).id == b1.id
    end
  end
end
