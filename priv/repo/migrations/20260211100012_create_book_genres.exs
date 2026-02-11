defmodule TheStoryVoyageApi.Repo.Migrations.CreateBookGenres do
  use Ecto.Migration

  def change do
    create table(:book_genres) do
      add :book_id, references(:books, on_delete: :delete_all), null: false
      add :genre_id, references(:genres, on_delete: :delete_all), null: false
      add :vote_count, :integer, default: 0
    end

    create unique_index(:book_genres, [:book_id, :genre_id])
    create index(:book_genres, [:genre_id])
  end
end
