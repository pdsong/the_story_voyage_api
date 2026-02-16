defmodule TheStoryVoyageApi.Repo.Migrations.CreateBuddyReadParticipants do
  use Ecto.Migration

  def change do
    create table(:buddy_read_participants) do
      add :buddy_read_id, references(:buddy_reads, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:buddy_read_participants, [:buddy_read_id])
    create index(:buddy_read_participants, [:user_id])
    create unique_index(:buddy_read_participants, [:buddy_read_id, :user_id])
  end
end
