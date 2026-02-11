defmodule TheStoryVoyageApi.Accounts.UserBlock do
  @moduledoc """
  Schema for user block relationships.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_blocks" do
    belongs_to :blocker, TheStoryVoyageApi.Accounts.User
    belongs_to :blocked, TheStoryVoyageApi.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(block, attrs) do
    block
    |> cast(attrs, [:blocker_id, :blocked_id])
    |> validate_required([:blocker_id, :blocked_id])
    |> unique_constraint([:blocker_id, :blocked_id])
    |> foreign_key_constraint(:blocker_id)
    |> foreign_key_constraint(:blocked_id)
  end
end
