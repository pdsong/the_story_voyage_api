defmodule TheStoryVoyageApiWeb.StatsJSON do
  alias TheStoryVoyageApiWeb.BookJSON

  @doc """
  Renders user stats overview.
  """
  def show(%{stats: stats}) do
    %{data: stats}
  end

  @doc """
  Renders year stats.
  """
  def show_year(%{stats: stats}) do
    %{data: stats}
  end

  def comparison_year(%{stats: stats}) do
    %{data: stats}
  end

  def comparison(%{stats: stats}) do
    %{data: stats}
  end

  def heatmap(%{data: data}) do
    %{data: data}
  end

  def wrap_up(%{summary: summary}) do
    %{
      data: %{
        period: summary.period,
        total_books: summary.total_books,
        total_pages: summary.total_pages,
        top_books: Enum.map(summary.top_books, &user_book_data/1),
        most_read_genre: summary.most_read_genre
      }
    }
  end

  @doc """
  Renders distribution data.
  """
  def distribution(%{data: data}) do
    %{data: data}
  end

  defp user_book_data(user_book) do
    %{
      rating: user_book.rating,
      read_at: user_book.updated_at,
      book: BookJSON.data(user_book.book)
    }
  end
end
