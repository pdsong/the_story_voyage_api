defmodule TheStoryVoyageApi.Books.Book do
  @moduledoc """
  Schema for the books table — the central entity of the platform.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :title, :string
    field :original_title, :string
    field :description, :string
    field :pace, :string
    field :character_or_plot, :string
    field :average_rating, :float, default: 0.0
    field :ratings_count, :integer, default: 0
    field :pages, :integer
    field :first_published, :date
    field :series_position, :float

    belongs_to :series, TheStoryVoyageApi.Books.Series
    has_many :editions, TheStoryVoyageApi.Books.Edition

    many_to_many :authors, TheStoryVoyageApi.Books.Author,
      join_through: "book_authors",
      on_replace: :delete

    many_to_many :genres, TheStoryVoyageApi.Books.Genre,
      join_through: "book_genres",
      on_replace: :delete

    many_to_many :moods, TheStoryVoyageApi.Books.Mood,
      join_through: "book_moods",
      on_replace: :delete

    many_to_many :content_warnings, TheStoryVoyageApi.Books.ContentWarning,
      join_through: TheStoryVoyageApi.Books.BookContentWarning,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @required_fields [:title]
  @optional_fields [
    :original_title,
    :description,
    :pace,
    :character_or_plot,
    :average_rating,
    :ratings_count,
    :pages,
    :first_published,
    :series_id,
    :series_position
  ]

  def changeset(book, attrs) do
    book
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:title, min: 1, max: 500)
    |> validate_inclusion(:pace, ["slow", "medium", "fast", nil])
    |> validate_inclusion(:character_or_plot, ["character", "plot", "both", nil])
    |> validate_number(:average_rating, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 5.0)
    |> validate_number(:ratings_count, greater_than_or_equal_to: 0)
    |> validate_number(:pages, greater_than: 0)
    |> foreign_key_constraint(:series_id)
  end
end
