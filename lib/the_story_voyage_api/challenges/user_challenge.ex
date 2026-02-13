defmodule TheStoryVoyageApi.Challenges.UserChallenge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_challenges" do
    field :status, :string, default: "joined"
    belongs_to :user, TheStoryVoyageApi.Accounts.User
    belongs_to :challenge, TheStoryVoyageApi.Challenges.Challenge

    has_many :entries, TheStoryVoyageApi.Challenges.UserChallengeEntry

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_challenge, attrs) do
    user_challenge
    |> cast(attrs, [:status, :user_id, :challenge_id])
    |> validate_required([:user_id, :challenge_id])
    |> unique_constraint([:user_id, :challenge_id])
  end
end
