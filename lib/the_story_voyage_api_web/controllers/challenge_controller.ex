defmodule TheStoryVoyageApiWeb.ChallengeController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Challenges
  alias TheStoryVoyageApi.Challenges.UserChallenge

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, _params) do
    challenges = Challenges.list_challenges()
    render(conn, :index, challenges: challenges)
  end

  def show(conn, %{"id" => id}) do
    challenge = Challenges.get_challenge!(id)
    render(conn, :show, challenge: challenge)
  end

  def join(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with {:ok, %UserChallenge{} = user_challenge} <- Challenges.join_challenge(user, id) do
      # Preload for rendering? Or just return basic info.
      # Let's reload to be safe if we need associations, but basic insert result is usually fine.
      # UserChallenge belongs_to challenge.
      user_challenge = TheStoryVoyageApi.Repo.preload(user_challenge, challenge: :prompts)

      conn
      |> put_status(:created)
      |> put_view(TheStoryVoyageApiWeb.ChallengeJSON)
      |> render(:user_show, user_challenge: user_challenge)
    end
  end

  def add_entry(conn, %{"id" => id, "entry" => entry_params}) do
    user = conn.assigns.current_user

    with {:ok, entry} <- Challenges.add_entry(user, id, entry_params) do
      conn
      |> put_status(:created)
      |> json(%{data: %{id: entry.id, status: "created"}})

      # Or meaningful response. Use ChallengeJSON.entry_data
      # For simplicity, returning simple JSON or reusing a view.
    end
  end
end
