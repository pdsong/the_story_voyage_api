defmodule TheStoryVoyageApi.Reading do
  @moduledoc """
  The Reading context.
  """
  import Ecto.Query, warn: false
  alias TheStoryVoyageApi.Repo

  alias TheStoryVoyageApi.Reading.UserBookTag
  alias TheStoryVoyageApi.Accounts.UserBook

  @doc """
  Adds a tag to a user book entry.
  """
  def add_tag(%UserBook{} = user_book, tag_name) do
    %UserBookTag{}
    |> UserBookTag.changeset(%{user_book_id: user_book.id, tag_name: tag_name})
    |> Repo.insert()
  end

  @doc """
  Removes a tag from a user book entry.
  """
  def remove_tag(%UserBook{} = user_book, tag_name) do
    tag_name = String.downcase(String.trim(tag_name))

    from(t in UserBookTag,
      where: t.user_book_id == ^user_book.id and t.tag_name == ^tag_name
    )
    |> Repo.delete_all()

    {:ok, :deleted}
  end

  @doc """
  Lists tags for a specific user book.
  """
  def list_tags(%UserBook{} = user_book) do
    Repo.all(
      from t in UserBookTag,
        where: t.user_book_id == ^user_book.id,
        order_by: t.tag_name
    )
  end

  @doc """
  Lists all unique tags used by a user across all their books.
  """
  def list_user_tags(user_id) do
    query =
      from t in UserBookTag,
        join: ub in UserBook,
        on: t.user_book_id == ub.id,
        where: ub.user_id == ^user_id,
        distinct: true,
        select: t.tag_name,
        order_by: t.tag_name

    Repo.all(query)
  end
end
