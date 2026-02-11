defmodule TheStoryVoyageApi.Repo.Migrations.CreateGenres do
  use Ecto.Migration

  def change do
    create table(:genres) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :parent_id, references(:genres, on_delete: :nilify_all)
    end

    create unique_index(:genres, [:name])
    create unique_index(:genres, [:slug])
  end
end
