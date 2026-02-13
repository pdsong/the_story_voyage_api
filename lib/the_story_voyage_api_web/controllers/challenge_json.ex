defmodule TheStoryVoyageApiWeb.ChallengeJSON do
  alias TheStoryVoyageApi.Challenges.{Challenge, UserChallenge, UserChallengeEntry}

  # Challenges
  def index(%{challenges: challenges}) do
    %{data: for(challenge <- challenges, do: data(challenge))}
  end

  def show(%{challenge: challenge}) do
    %{data: data(challenge)}
  end

  def data(%Challenge{} = challenge) do
    %{
      id: challenge.id,
      title: challenge.title,
      description: challenge.description,
      prompts:
        for(
          prompt <- Enum.sort_by(challenge.prompts || [], & &1.order_index),
          do: prompt_data(prompt)
        )
    }
  end

  def prompt_data(prompt) do
    %{
      id: prompt.id,
      description: prompt.description,
      order: prompt.order_index
    }
  end

  # User Challenges
  def user_index(%{user_challenges: user_challenges}) do
    %{data: for(uc <- user_challenges, do: user_challenge_data(uc))}
  end

  def user_show(%{user_challenge: user_challenge}) do
    %{data: user_challenge_data(user_challenge)}
  end

  def user_challenge_data(%UserChallenge{} = uc) do
    base = %{
      id: uc.id,
      challenge_id: uc.challenge_id,
      status: uc.status,
      challenge: if(Ecto.assoc_loaded?(uc.challenge), do: data(uc.challenge), else: nil)
    }

    if Ecto.assoc_loaded?(uc.entries) do
      Map.put(base, :entries, for(e <- uc.entries, do: entry_data(e)))
    else
      base
    end
  end

  def entry_data(%UserChallengeEntry{} = entry) do
    %{
      id: entry.id,
      prompt_id: entry.prompt_id,
      user_book_id: entry.user_book_id
    }
  end
end
