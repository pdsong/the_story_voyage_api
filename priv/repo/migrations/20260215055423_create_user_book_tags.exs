defmodule TheStoryVoyageApi.Repo.Migrations.CreateUserBookTags do
  use Ecto.Migration

  def change do
    create table(:user_book_tags) do
      add :user_book_id, references(:user_books, on_delete: :delete_all), null: false
      add :tag_name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_book_tags, [:user_book_id, :tag_name])
    create index(:user_book_tags, [:tag_name])
    create index(:user_book_tags, [:user_book_id])
  end
end
