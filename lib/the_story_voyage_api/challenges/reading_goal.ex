defmodule TheStoryVoyageApi.Challenges.ReadingGoal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reading_goals" do
    field :year, :integer
    field :target, :integer
    belongs_to :user, TheStoryVoyageApi.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reading_goal, attrs) do
    reading_goal
    |> cast(attrs, [:year, :target, :user_id])
    |> validate_required([:year, :target, :user_id])
    |> validate_number(:target, greater_than: 0)
    |> validate_number(:year, greater_than: 2000)
    |> unique_constraint([:user_id, :year])
  end
end
