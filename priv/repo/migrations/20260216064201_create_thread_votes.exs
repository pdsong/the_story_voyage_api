defmodule TheStoryVoyageApi.Repo.Migrations.CreateThreadVotes do
  use Ecto.Migration

  def change do
    create table(:thread_votes) do
      add :thread_id, references(:club_threads, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:thread_votes, [:thread_id])
    create index(:thread_votes, [:user_id])
    create unique_index(:thread_votes, [:thread_id, :user_id])
  end
end
