defmodule TheStoryVoyageApi.Repo.Migrations.CreateClubThreads do
  use Ecto.Migration

  def change do
    create table(:club_threads) do
      add :title, :string
      add :content, :text
      add :vote_count, :integer
      add :club_id, references(:clubs, on_delete: :delete_all)
      add :creator_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:club_threads, [:club_id])
    create index(:club_threads, [:creator_id])
  end
end
