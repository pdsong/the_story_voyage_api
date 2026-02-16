defmodule TheStoryVoyageApi.Communities.ClubThread do
  use Ecto.Schema
  import Ecto.Changeset

  alias TheStoryVoyageApi.Communities.Club
  alias TheStoryVoyageApi.Accounts.User

  schema "club_threads" do
    field :title, :string
    field :content, :string
    field :vote_count, :integer
    belongs_to :club, Club
    belongs_to :creator, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(club_thread, attrs) do
    club_thread
    |> cast(attrs, [:title, :content, :vote_count, :club_id, :creator_id])
    |> validate_required([:title, :content, :club_id, :creator_id])
  end
end
