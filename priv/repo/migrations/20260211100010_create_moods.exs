defmodule TheStoryVoyageApi.Repo.Migrations.CreateMoods do
  use Ecto.Migration

  def change do
    create table(:moods) do
      add :name, :string, null: false
      add :slug, :string, null: false
    end

    create unique_index(:moods, [:name])
    create unique_index(:moods, [:slug])
  end
end
