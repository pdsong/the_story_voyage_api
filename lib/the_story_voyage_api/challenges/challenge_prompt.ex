defmodule TheStoryVoyageApi.Challenges.ChallengePrompt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "challenge_prompts" do
    field :description, :string
    field :order_index, :integer
    belongs_to :challenge, TheStoryVoyageApi.Challenges.Challenge

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [:description, :order_index, :challenge_id])
    |> validate_required([:description, :challenge_id])
  end
end
