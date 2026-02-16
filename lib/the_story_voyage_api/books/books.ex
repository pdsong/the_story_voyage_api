defmodule TheStoryVoyageApi.Books do
  @moduledoc """
  The Books context — manages books, authors, editions, genres, moods, and content warnings.
  """
  import Ecto.Query
  alias TheStoryVoyageApi.Repo
  alias TheStoryVoyageApi.Books.{Book, Author, Edition, Genre, Mood, ContentWarning, Series}

  # ========== Books ==========

  @doc "Returns a book by ID, preloading associations. Raises if not found."
  def get_book!(id) do
    Book
    |> Repo.get!(id)
    |> Repo.preload([:authors, :genres, :moods, :editions, :series, :content_warnings])
  end

  @doc "Returns a book by ID, preloading associations."
  def get_book(id) do
    Book
    |> Repo.get(id)
    |> Repo.preload([:authors, :genres, :moods, :editions, :series, :content_warnings])
  end

  @doc "Lists books with optional filtering (search, genre, mood) and pagination."
  def list_books(params \\ %{}) do
    limit = Map.get(params, "limit", 20)
    offset = Map.get(params, "offset", 0)

    Book
    |> search_by_keyword(params["q"])
    |> filter_by_genre(params["genre_id"])
    |> filter_by_mood(params["mood_id"])
    |> limit(^limit)
    |> offset(^offset)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload([:authors, :genres, :moods, :content_warnings])
  end

  defp search_by_keyword(query, nil), do: query
  defp search_by_keyword(query, ""), do: query

  defp search_by_keyword(query, keyword) do
    term = "%#{keyword}%"
    from b in query, where: like(b.title, ^term) or like(b.description, ^term)
  end

  defp filter_by_genre(query, nil), do: query
  defp filter_by_genre(query, ""), do: query

  defp filter_by_genre(query, genre_id) do
    from b in query,
      join: g in assoc(b, :genres),
      where: g.id == ^genre_id
  end

  defp filter_by_mood(query, nil), do: query
  defp filter_by_mood(query, ""), do: query

  defp filter_by_mood(query, mood_id) do
    from b in query,
      join: m in assoc(b, :moods),
      where: m.id == ^mood_id
  end

  @doc "Creates a new book with associations."
  def create_book(attrs) do
    authors = get_entities_by_ids(Author, attrs["author_ids"])
    genres = get_entities_by_ids(Genre, attrs["genre_ids"])
    moods = get_entities_by_ids(Mood, attrs["mood_ids"])

    %Book{}
    |> Book.changeset(attrs)
    |> put_assoc_if_loaded(:authors, authors)
    |> put_assoc_if_loaded(:genres, genres)
    |> put_assoc_if_loaded(:moods, moods)
    |> Repo.insert()
  end

  @doc "Updates a book with associations."
  def update_book(%Book{} = book, attrs) do
    authors = get_entities_by_ids(Author, attrs["author_ids"])
    genres = get_entities_by_ids(Genre, attrs["genre_ids"])
    moods = get_entities_by_ids(Mood, attrs["mood_ids"])

    book
    |> Repo.preload([:authors, :genres, :moods])
    |> Book.changeset(attrs)
    |> put_assoc_if_loaded(:authors, authors)
    |> put_assoc_if_loaded(:genres, genres)
    |> put_assoc_if_loaded(:moods, moods)
    |> Repo.update()
  end

  defp get_entities_by_ids(schema, ids) when is_list(ids) do
    Repo.all(from e in schema, where: e.id in ^ids)
  end

  defp get_entities_by_ids(_schema, _), do: nil

  defp put_assoc_if_loaded(changeset, _key, nil), do: changeset

  defp put_assoc_if_loaded(changeset, key, entities),
    do: Ecto.Changeset.put_assoc(changeset, key, entities)

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

  def create_genre(attrs) do
    %Genre{}
    |> Genre.changeset(attrs)
    |> Repo.insert()
  end

  def get_genre_by_slug(slug) do
    Repo.get_by(Genre, slug: slug)
  end

  # ========== Moods ==========

  def list_moods do
    Repo.all(Mood)
  end

  def create_mood(attrs) do
    %Mood{}
    |> Mood.changeset(attrs)
    |> Repo.insert()
  end

  def get_mood_by_slug(slug) do
    Repo.get_by(Mood, slug: slug)
  end

  # ========== Content Warnings ==========

  def list_content_warnings do
    Repo.all(ContentWarning)
  end

  def create_content_warning(attrs) do
    %ContentWarning{}
    |> ContentWarning.changeset(attrs)
    |> Repo.insert()
  end

  def add_content_warning(book, content_warning_id, user) do
    %TheStoryVoyageApi.Books.BookContentWarning{}
    |> TheStoryVoyageApi.Books.BookContentWarning.changeset(%{
      book_id: book.id,
      content_warning_id: content_warning_id,
      reported_by_user_id: user.id
    })
    |> Repo.insert()
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
