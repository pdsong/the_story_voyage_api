defmodule TheStoryVoyageApi.Repo.Migrations.CreateBookAuthors do
  use Ecto.Migration

  def change do
    create table(:book_authors) do
      add :book_id, references(:books, on_delete: :delete_all), null: false
      add :author_id, references(:authors, on_delete: :delete_all), null: false
      add :role, :string, default: "author"
    end

    create unique_index(:book_authors, [:book_id, :author_id])
    create index(:book_authors, [:author_id])
  end
end
