defmodule TheStoryVoyageApi.Repo.Migrations.CreateBookMoods do
  use Ecto.Migration

  def change do
    create table(:book_moods) do
      add :book_id, references(:books, on_delete: :delete_all), null: false
      add :mood_id, references(:moods, on_delete: :delete_all), null: false
      add :vote_count, :integer, default: 0
    end

    create unique_index(:book_moods, [:book_id, :mood_id])
    create index(:book_moods, [:mood_id])
  end
end
