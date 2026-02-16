defmodule TheStoryVoyageApi.Communities.ClubMember do
  use Ecto.Schema
  import Ecto.Changeset

  alias TheStoryVoyageApi.Communities.Club
  alias TheStoryVoyageApi.Accounts.User

  schema "club_members" do
    field :role, :string
    field :status, :string
    belongs_to :club, Club
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(club_member, attrs) do
    club_member
    |> cast(attrs, [:role, :status, :club_id, :user_id])
    |> validate_required([:role, :status, :club_id, :user_id])
  end
end
