defmodule TheStoryVoyageApi.Communities.BuddyReadParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  # alias TheStoryVoyageApi.Communities.BuddyRead
  # alias TheStoryVoyageApi.Accounts.User

  schema "buddy_read_participants" do
    belongs_to :buddy_read, TheStoryVoyageApi.Communities.BuddyRead
    belongs_to :user, TheStoryVoyageApi.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(buddy_read_participant, attrs) do
    buddy_read_participant
    |> cast(attrs, [:buddy_read_id, :user_id])
    |> validate_required([:buddy_read_id, :user_id])
    |> unique_constraint([:buddy_read_id, :user_id])
  end
end
