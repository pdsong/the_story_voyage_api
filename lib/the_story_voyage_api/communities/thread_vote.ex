defmodule TheStoryVoyageApi.Communities.ThreadVote do
  use Ecto.Schema
  import Ecto.Changeset

  alias TheStoryVoyageApi.Communities.ClubThread
  alias TheStoryVoyageApi.Accounts.User

  schema "thread_votes" do
    belongs_to :thread, ClubThread
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(thread_vote, attrs) do
    thread_vote
    |> cast(attrs, [:thread_id, :user_id])
    |> validate_required([:thread_id, :user_id])
    |> unique_constraint([:thread_id, :user_id])
  end
end
