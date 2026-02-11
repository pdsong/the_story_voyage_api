defmodule TheStoryVoyageApi.Repo.Migrations.CreateContentWarnings do
  use Ecto.Migration

  def change do
    create table(:content_warnings) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :category, :string
    end

    create unique_index(:content_warnings, [:name])
    create unique_index(:content_warnings, [:slug])
  end
end
