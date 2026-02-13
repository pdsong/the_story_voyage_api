defmodule TheStoryVoyageApi.Accounts.UserBook do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_books" do
    field :status, :string
    field :rating, :float
    field :notes, :string
    field :review_title, :string
    field :review_content, :string
    field :review_contains_spoilers, :boolean, default: false

    belongs_to :user, TheStoryVoyageApi.Accounts.User
    belongs_to :book, TheStoryVoyageApi.Books.Book

    timestamps(type: :utc_datetime)
  end

  @valid_statuses ["want_to_read", "reading", "read", "did_not_finish"]

  def changeset(user_book, attrs) do
    user_book
    |> cast(attrs, [
      :status,
      :rating,
      :notes,
      :user_id,
      :book_id,
      :review_title,
      :review_content,
      :review_contains_spoilers
    ])
    |> validate_required([:status, :user_id, :book_id])
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_number(:rating, greater_than_or_equal_to: 0.25, less_than_or_equal_to: 5.0)
    # TODO: Validate increment of 0.25 if strictly required, but float range is safer for now.
    |> validate_length(:review_title, max: 100)
    |> validate_length(:review_content, max: 2000)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:book_id)
    |> unique_constraint([:user_id, :book_id])
  end
end
