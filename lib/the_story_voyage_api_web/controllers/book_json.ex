defmodule TheStoryVoyageApiWeb.BookJSON do
  alias TheStoryVoyageApi.Books.Book

  @doc """
  Renders a list of books.
  """
  def index(%{books: books}) do
    %{data: for(book <- books, do: data(book))}
  end

  @doc """
  Renders a single book.
  """
  def show(%{book: book}) do
    %{data: data(book)}
  end

  def data(%Book{} = book) do
    %{
      id: book.id,
      title: book.title,
      original_title: book.original_title,
      description: book.description,
      pace: book.pace,
      character_or_plot: book.character_or_plot,
      average_rating: book.average_rating,
      ratings_count: book.ratings_count,
      first_published: book.first_published,
      series_position: book.series_position,
      authors: for(author <- book.authors || [], do: %{id: author.id, name: author.name}),
      genres:
        for(genre <- book.genres || [], do: %{id: genre.id, name: genre.name, slug: genre.slug}),
      moods: for(mood <- book.moods || [], do: %{id: mood.id, name: mood.name, slug: mood.slug}),
      content_warnings:
        for(
          cw <- book.content_warnings || [],
          do: %{id: cw.id, name: cw.name, category: cw.category}
        )
    }
  end
end
