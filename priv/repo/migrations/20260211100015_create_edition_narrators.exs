defmodule TheStoryVoyageApi.Repo.Migrations.CreateEditionNarrators do
  use Ecto.Migration

  def change do
    create table(:edition_narrators) do
      add :edition_id, references(:editions, on_delete: :delete_all), null: false
      add :name, :string, null: false
    end

    create unique_index(:edition_narrators, [:edition_id, :name])
  end
end
