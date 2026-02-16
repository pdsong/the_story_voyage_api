defmodule TheStoryVoyageApi.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :type, :string
    field :data, :map, default: %{}
    field :read_at, :utc_datetime

    belongs_to :recipient, TheStoryVoyageApi.Accounts.User
    belongs_to :actor, TheStoryVoyageApi.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:recipient_id, :actor_id, :type, :data, :read_at])
    |> validate_required([:recipient_id, :type])
    |> validate_inclusion(:type, [
      "new_follower",
      "friend_request_received",
      "friend_request_accepted"
    ])
  end
end
