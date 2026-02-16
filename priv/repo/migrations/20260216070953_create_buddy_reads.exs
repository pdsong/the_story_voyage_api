defmodule TheStoryVoyageApi.Repo.Migrations.CreateBuddyReads do
  use Ecto.Migration

  def change do
    create table(:buddy_reads) do
      add :start_date, :date
      add :status, :string
      add :book_id, references(:books, on_delete: :nothing)
      add :creator_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:buddy_reads, [:book_id])
    create index(:buddy_reads, [:creator_id])
  end
end
