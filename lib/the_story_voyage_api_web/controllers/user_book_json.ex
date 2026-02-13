defmodule TheStoryVoyageApiWeb.UserBookJSON do
  alias TheStoryVoyageApi.Accounts.UserBook
  alias TheStoryVoyageApiWeb.BookJSON

  @doc """
  Renders a list of user books.
  """
  def index(%{user_books: user_books}) do
    %{data: for(ub <- user_books, do: data(ub))}
  end

  @doc """
  Renders a single user book.
  """
  def show(%{user_book: user_book}) do
    %{data: data(user_book)}
  end

  def data(%UserBook{} = ub) do
    %{
      status: ub.status,
      rating: ub.rating,
      notes: ub.notes,
      book_id: ub.book_id,
      book: if(Ecto.assoc_loaded?(ub.book), do: BookJSON.data(ub.book), else: nil),
      review_title: ub.review_title,
      review_content: ub.review_content,
      review_contains_spoilers: ub.review_contains_spoilers,
      inserted_at: ub.inserted_at,
      updated_at: ub.updated_at
    }
  end
end
