defmodule TheStoryVoyageApi.Books.Genre do
  @moduledoc """
  Schema for book genres with hierarchical support via parent_id.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "genres" do
    field :name, :string
    field :slug, :string

    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id

    many_to_many :books, TheStoryVoyageApi.Books.Book, join_through: "book_genres"
  end

  def changeset(genre, attrs) do
    genre
    |> cast(attrs, [:name, :slug, :parent_id])
    |> validate_required([:name, :slug])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:parent_id)
  end
end
