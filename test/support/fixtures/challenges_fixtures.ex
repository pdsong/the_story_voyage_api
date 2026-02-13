defmodule TheStoryVoyageApi.ChallengesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheStoryVoyageApi.Challenges` context.
  """

  alias TheStoryVoyageApi.Challenges

  def reading_goal_fixture(user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        year: 2026,
        target: 50
      })

    {:ok, reading_goal} = Challenges.set_reading_goal(user, attrs)

    reading_goal
  end

  def challenge_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "2026 Reading Challenge",
        description: "Read 50 books in 2026",
        start_date: ~D[2026-01-01],
        end_date: ~D[2026-12-31],
        type: "official"
      })

    {:ok, challenge} = Challenges.create_challenge(attrs)

    challenge
  end

  def prompt_fixture(challenge, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "A book with a blue cover",
        order_index: 0,
        challenge_id: challenge.id
      })

    {:ok, prompt} = Challenges.create_challenge_prompt(attrs)

    prompt
  end
end
