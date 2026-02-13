defmodule TheStoryVoyageApi.Challenges.UserChallengeEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_challenge_entries" do
    belongs_to :user_challenge, TheStoryVoyageApi.Challenges.UserChallenge
    belongs_to :prompt, TheStoryVoyageApi.Challenges.ChallengePrompt
    belongs_to :user_book, TheStoryVoyageApi.Accounts.UserBook

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:user_challenge_id, :prompt_id, :user_book_id])
    |> validate_required([:user_challenge_id, :prompt_id, :user_book_id])
    |> unique_constraint([:user_challenge_id, :prompt_id])
  end
end
