defmodule TheStoryVoyageApi.Communities.Readalong do
  use Ecto.Schema
  import Ecto.Changeset

  alias TheStoryVoyageApi.Books.Book
  alias TheStoryVoyageApi.Accounts.User
  alias TheStoryVoyageApi.Communities.{ReadalongSection, ReadalongParticipant}

  schema "readalongs" do
    field :title, :string
    field :description, :string
    field :start_date, :date

    belongs_to :book, Book
    belongs_to :owner, User
    has_many :sections, ReadalongSection
    has_many :participants, ReadalongParticipant

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(readalong, attrs) do
    readalong
    |> cast(attrs, [:title, :description, :start_date, :book_id, :owner_id])
    |> validate_required([:title, :start_date, :book_id, :owner_id])
    |> cast_assoc(:sections, with: &ReadalongSection.changeset/2)
  end
end
