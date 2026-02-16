defmodule TheStoryVoyageApi.Repo.Migrations.CreateClubMembers do
  use Ecto.Migration

  def change do
    create table(:club_members) do
      add :role, :string
      add :status, :string
      add :club_id, references(:clubs, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:club_members, [:club_id])
    create index(:club_members, [:user_id])
    create unique_index(:club_members, [:club_id, :user_id])
  end
end
