defmodule TheStoryVoyageApi.Communities.ReadalongParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  alias TheStoryVoyageApi.Communities.Readalong
  alias TheStoryVoyageApi.Accounts.User

  schema "readalong_participants" do
    belongs_to :readalong, Readalong
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:readalong_id, :user_id])
    |> validate_required([:readalong_id, :user_id])
    |> unique_constraint([:readalong_id, :user_id])
  end
end
