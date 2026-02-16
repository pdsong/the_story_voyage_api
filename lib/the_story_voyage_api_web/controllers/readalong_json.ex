defmodule TheStoryVoyageApiWeb.ReadalongJSON do
  alias TheStoryVoyageApi.Communities.Readalong

  @doc """
  Renders a list of readalongs.
  """
  def index(%{readalongs: readalongs}) do
    %{data: for(readalong <- readalongs, do: data(readalong))}
  end

  @doc """
  Renders a single readalong.
  """
  def show(%{readalong: readalong}) do
    %{data: data(readalong)}
  end

  defp data(%Readalong{} = readalong) do
    %{
      id: readalong.id,
      title: readalong.title,
      description: readalong.description,
      start_date: readalong.start_date,
      owner_id: readalong.owner_id,
      book: book_data(readalong.book),
      sections: sections_data(readalong.sections)
    }
  end

  defp book_data(%Ecto.Association.NotLoaded{}), do: nil
  defp book_data(nil), do: nil

  defp book_data(book) do
    %{
      id: book.id,
      title: book.title
    }
  end

  defp sections_data(%Ecto.Association.NotLoaded{}), do: []

  defp sections_data(sections) do
    for section <- sections do
      %{
        id: section.id,
        title: section.title,
        start_chapter: section.start_chapter,
        end_chapter: section.end_chapter,
        unlock_date: section.unlock_date
      }
    end
  end
end
