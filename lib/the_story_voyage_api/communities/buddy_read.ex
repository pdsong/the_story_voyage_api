defmodule TheStoryVoyageApi.Communities.BuddyRead do
  use Ecto.Schema
  import Ecto.Changeset

  alias TheStoryVoyageApi.Books.Book
  alias TheStoryVoyageApi.Accounts.User
  alias TheStoryVoyageApi.Books.Book
  alias TheStoryVoyageApi.Accounts.User
  # alias TheStoryVoyageApi.Communities.BuddyReadParticipant

  schema "buddy_reads" do
    field :start_date, :date
    field :status, :string, default: "active"
    belongs_to :book, Book
    belongs_to :creator, User

    # has_many :participants, Module.concat(["TheStoryVoyageApi.Communities.BuddyReadParticipant"])

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(buddy_read, attrs) do
    buddy_read
    |> cast(attrs, [:start_date, :status, :book_id, :creator_id])
    |> validate_required([:start_date, :status, :book_id, :creator_id])
  end
end
