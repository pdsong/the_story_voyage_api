defmodule TheStoryVoyageApi.Repo.Migrations.CreateClubs do
  use Ecto.Migration

  def change do
    create table(:clubs) do
      add :name, :string
      add :description, :text
      add :is_private, :boolean, default: false, null: false
      add :owner_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:clubs, [:owner_id])
  end
end
