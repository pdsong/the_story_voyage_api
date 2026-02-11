defmodule TheStoryVoyageApi.Books.Mood do
  @moduledoc """
  Schema for reading moods/feelings associated with books.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "moods" do
    field :name, :string
    field :slug, :string

    many_to_many :books, TheStoryVoyageApi.Books.Book, join_through: "book_moods"
  end

  def changeset(mood, attrs) do
    mood
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end
