defmodule TheStoryVoyageApi.Challenges.Challenge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "challenges" do
    field :title, :string
    field :description, :string
    field :start_date, :date
    field :end_date, :date
    field :type, :string, default: "official"

    has_many :prompts, TheStoryVoyageApi.Challenges.ChallengePrompt

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:title, :description, :start_date, :end_date, :type])
    |> validate_required([:title, :type])
  end
end
