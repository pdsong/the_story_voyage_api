defmodule TheStoryVoyageApi.Repo.Migrations.CreateSeries do
  use Ecto.Migration

  def change do
    create table(:series) do
      add :name, :string, null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create index(:series, [:name])
  end
end
