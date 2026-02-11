defmodule TheStoryVoyageApi.Books.Series do
  @moduledoc """
  Schema for book series.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "series" do
    field :name, :string
    field :description, :string

    has_many :books, TheStoryVoyageApi.Books.Book

    timestamps(type: :utc_datetime)
  end

  def changeset(series, attrs) do
    series
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
  end
end
