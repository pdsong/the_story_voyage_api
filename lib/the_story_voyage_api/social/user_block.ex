defmodule TheStoryVoyageApi.Social.UserBlock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_blocks" do
    belongs_to :blocker, TheStoryVoyageApi.Accounts.User
    belongs_to :blocked, TheStoryVoyageApi.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(user_block, attrs) do
    user_block
    |> cast(attrs, [:blocker_id, :blocked_id])
    |> validate_required([:blocker_id, :blocked_id])
    |> unique_constraint([:blocker_id, :blocked_id])
  end
end
