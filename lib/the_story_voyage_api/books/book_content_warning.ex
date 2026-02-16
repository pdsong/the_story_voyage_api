defmodule TheStoryVoyageApi.Books.BookContentWarning do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_content_warnings" do
    belongs_to :book, TheStoryVoyageApi.Books.Book
    belongs_to :content_warning, TheStoryVoyageApi.Books.ContentWarning
    belongs_to :reported_by_user, TheStoryVoyageApi.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(book_content_warning, attrs) do
    book_content_warning
    |> cast(attrs, [:book_id, :content_warning_id, :reported_by_user_id])
    |> validate_required([:book_id, :content_warning_id])
    |> unique_constraint([:book_id, :content_warning_id, :reported_by_user_id])
  end
end
