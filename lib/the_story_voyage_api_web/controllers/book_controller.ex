defmodule TheStoryVoyageApiWeb.BookController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Books
  alias TheStoryVoyageApi.Books.Book

  action_fallback TheStoryVoyageApiWeb.FallbackController

  # Public access
  use OpenApiSpex.ControllerSpecs

  tags(["Books"])

  @doc "GET /api/v1/books"
  operation(:index,
    summary: "List books",
    parameters: [
      min_rating: [in: :query, type: :number, description: "Minimum rating"],
      genre_id: [in: :query, type: :integer, description: "Filter by genre ID"]
    ],
    responses: %{
      200 => {"List of books", "application/json", TheStoryVoyageApiWeb.Schemas.BookListResponse}
    }
  )

  def index(conn, params) do
    books = Books.list_books(params)
    render(conn, :index, books: books)
  end

  @doc "GET /api/v1/books/:id"
  operation(:show,
    summary: "Get a book by ID",
    parameters: [
      id: [in: :path, type: :integer, description: "Book ID", required: true]
    ],
    responses: %{
      200 => {"Book details", "application/json", TheStoryVoyageApiWeb.Schemas.BookResponse},
      404 => {"Not Found", "application/json", %OpenApiSpex.Schema{type: :object}}
    }
  )

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
