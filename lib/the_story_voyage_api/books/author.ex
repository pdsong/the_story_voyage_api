defmodule TheStoryVoyageApi.Books.Author do
  @moduledoc """
  Schema for the authors table.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :name, :string
    field :bio, :string
    field :photo_url, :string
    field :born_date, :date
    field :nationality, :string

    many_to_many :books, TheStoryVoyageApi.Books.Book, join_through: "book_authors"

    timestamps(type: :utc_datetime)
  end

  @required_fields [:name]
  @optional_fields [:bio, :photo_url, :born_date, :nationality]

  def changeset(author, attrs) do
    author
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 1, max: 255)
  end
end
