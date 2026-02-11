defmodule TheStoryVoyageApi.Books do
  @moduledoc """
  The Books context — manages books, authors, editions, genres, moods, and content warnings.
  """
  import Ecto.Query
  alias TheStoryVoyageApi.Repo
  alias TheStoryVoyageApi.Books.{Book, Author, Edition, Genre, Mood, ContentWarning, Series}

  # ========== Books ==========

  @doc "Returns a book by ID, preloading associations."
  def get_book(id) do
    Book
    |> Repo.get(id)
    |> Repo.preload([:authors, :genres, :moods, :editions, :series])
  end

  @doc "Lists books with optional filtering and pagination."
  def list_books(params \\ %{}) do
    limit = Map.get(params, "limit", 20)
    offset = Map.get(params, "offset", 0)

    Book
    |> limit(^limit)
    |> offset(^offset)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload([:authors, :genres, :moods])
  end

  @doc "Creates a new book."
  def create_book(attrs) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a book."
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  # ========== Authors ==========

  def get_author(id), do: Repo.get(Author, id)

  def create_author(attrs) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  def list_authors do
    Repo.all(Author)
  end

  # ========== Genres ==========

  def list_genres do
    Repo.all(Genre)
  end

  def get_genre_by_slug(slug) do
    Repo.get_by(Genre, slug: slug)
  end

  # ========== Moods ==========

  def list_moods do
    Repo.all(Mood)
  end

  def get_mood_by_slug(slug) do
    Repo.get_by(Mood, slug: slug)
  end

  # ========== Content Warnings ==========

  def list_content_warnings do
    Repo.all(ContentWarning)
  end

  # ========== Series ==========

  def get_series(id), do: Repo.get(Series, id) |> Repo.preload(:books)

  def create_series(attrs) do
    %Series{}
    |> Series.changeset(attrs)
    |> Repo.insert()
  end

  # ========== Editions ==========

  def get_edition(id), do: Repo.get(Edition, id)

  def create_edition(attrs) do
    %Edition{}
    |> Edition.changeset(attrs)
    |> Repo.insert()
  end

  def list_editions_for_book(book_id) do
    Edition
    |> where(book_id: ^book_id)
    |> Repo.all()
  end
end
