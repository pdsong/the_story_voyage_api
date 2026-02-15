defmodule TheStoryVoyageApi.Social.UserFollow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_follows" do
    belongs_to :follower, TheStoryVoyageApi.Accounts.User
    belongs_to :followed, TheStoryVoyageApi.Accounts.User
    field :is_friend, :boolean, default: false

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(user_follow, attrs) do
    user_follow
    |> cast(attrs, [:follower_id, :followed_id, :is_friend])
    |> validate_required([:follower_id, :followed_id])
    |> unique_constraint([:follower_id, :followed_id])
  end
end
