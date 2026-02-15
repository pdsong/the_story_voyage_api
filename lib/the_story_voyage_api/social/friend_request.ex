defmodule TheStoryVoyageApi.Social.FriendRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friend_requests" do
    belongs_to :sender, TheStoryVoyageApi.Accounts.User
    belongs_to :receiver, TheStoryVoyageApi.Accounts.User
    # pending, accepted, rejected
    field :status, :string, default: "pending"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(friend_request, attrs) do
    friend_request
    |> cast(attrs, [:sender_id, :receiver_id, :status])
    |> validate_required([:sender_id, :receiver_id, :status])
    |> validate_inclusion(:status, ["pending", "accepted", "rejected"])
    |> unique_constraint([:sender_id, :receiver_id])
  end
end
