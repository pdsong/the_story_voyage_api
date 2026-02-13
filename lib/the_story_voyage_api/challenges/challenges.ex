defmodule TheStoryVoyageApi.Challenges do
  @moduledoc """
  The Challenges context.
  """

  import Ecto.Query, warn: false
  alias TheStoryVoyageApi.Repo

  alias TheStoryVoyageApi.Challenges.{
    ReadingGoal,
    Challenge,
    ChallengePrompt,
    UserChallenge,
    UserChallengeEntry
  }

  alias TheStoryVoyageApi.Accounts.User

  # ========== Reading Goals ==========

  def get_reading_goal(%User{} = user, year) do
    Repo.get_by(ReadingGoal, user_id: user.id, year: year)
  end

  def list_reading_goals(%User{} = user) do
    ReadingGoal
    |> where([g], g.user_id == ^user.id)
    |> order_by(desc: :year)
    |> Repo.all()
  end

  def set_reading_goal(%User{} = user, attrs) do
    year = attrs["year"] || attrs[:year]

    case get_reading_goal(user, year) do
      nil ->
        %ReadingGoal{user_id: user.id}
        |> ReadingGoal.changeset(attrs)
        |> Repo.insert()

      existing_goal ->
        existing_goal
        |> ReadingGoal.changeset(attrs)
        |> Repo.update()
    end
  end

  # ========== Challenges ==========

  def list_challenges do
    Repo.all(Challenge) |> Repo.preload(:prompts)
  end

  def get_challenge!(id), do: Repo.get!(Challenge, id) |> Repo.preload(:prompts)

  def create_challenge(attrs) do
    %Challenge{}
    |> Challenge.changeset(attrs)
    |> Repo.insert()
  end

  def create_challenge_prompt(attrs) do
    %ChallengePrompt{}
    |> ChallengePrompt.changeset(attrs)
    |> Repo.insert()
  end

  # ========== User Challenges ==========

  def join_challenge(%User{} = user, challenge_id) do
    %UserChallenge{}
    |> UserChallenge.changeset(%{user_id: user.id, challenge_id: challenge_id, status: "joined"})
    |> Repo.insert()
  end

  def get_user_challenge(%User{} = user, challenge_id) do
    Repo.get_by(UserChallenge, user_id: user.id, challenge_id: challenge_id)
    |> Repo.preload(entries: [:prompt, :user_book])
  end

  def list_user_challenges(%User{} = user) do
    UserChallenge
    |> where([uc], uc.user_id == ^user.id)
    |> preload([:challenge])
    |> Repo.all()
  end

  def add_entry(%User{} = user, challenge_id, attrs) do
    # 1. Ensure user joined challenge
    case get_user_challenge(user, challenge_id) do
      nil ->
        {:error, :not_joined}

      user_challenge ->
        # 2. Add entry
        %UserChallengeEntry{}
        |> UserChallengeEntry.changeset(Map.put(attrs, "user_challenge_id", user_challenge.id))
        |> Repo.insert()
    end
  end
end
