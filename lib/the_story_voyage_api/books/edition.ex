defmodule TheStoryVoyageApi.Books.Edition do
  @moduledoc """
  Schema for book editions (specific ISBN / format / publisher).
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "editions" do
    field :isbn_10, :string
    field :isbn_13, :string
    field :format, :string
    field :page_count, :integer
    field :audio_duration_minutes, :integer
    field :publisher, :string
    field :publication_date, :date
    field :language, :string, default: "en"
    field :cover_image_url, :string

    belongs_to :book, TheStoryVoyageApi.Books.Book

    timestamps(type: :utc_datetime)
  end

  @required_fields [:book_id]
  @optional_fields [
    :isbn_10,
    :isbn_13,
    :format,
    :page_count,
    :audio_duration_minutes,
    :publisher,
    :publication_date,
    :language,
    :cover_image_url
  ]

  def changeset(edition, attrs) do
    edition
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:format, ["paperback", "hardcover", "ebook", "audiobook", nil])
    |> validate_number(:page_count, greater_than: 0)
    |> validate_number(:audio_duration_minutes, greater_than: 0)
    |> foreign_key_constraint(:book_id)
  end
end
