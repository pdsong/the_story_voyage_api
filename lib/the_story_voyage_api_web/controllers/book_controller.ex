defmodule TheStoryVoyageApiWeb.BookController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Books
  alias TheStoryVoyageApi.Books.Book

  action_fallback TheStoryVoyageApiWeb.FallbackController

  # Public access
  def index(conn, params) do
    books = Books.list_books(params)
    render(conn, :index, books: books)
  end

  def show(conn, %{"id" => id}) do
    book = Books.get_book(id)
    render(conn, :show, book: book)
  end

  # Admin/Librarian access
  def create(conn, %{"book" => book_params}) do
    with {:ok, %Book{} = book} <- Books.create_book(book_params) do
      # Reload to get associations
      book = Books.get_book(book.id)

      conn
      |> put_status(:created)
      # |> put_resp_header("location", ~p"/api/v1/books/#{book}")
      |> render(:show, book: book)
    end
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Books.get_book(id)

    with {:ok, %Book{} = book} <- Books.update_book(book, book_params) do
      # Reload to get associations
      book = Books.get_book(book.id)
      render(conn, :show, book: book)
    end
  end
end
