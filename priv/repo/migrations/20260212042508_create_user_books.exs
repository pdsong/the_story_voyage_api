defmodule TheStoryVoyageApi.Repo.Migrations.CreateUserBooks do
  use Ecto.Migration

  def change do
    create table(:user_books) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :book_id, references(:books, on_delete: :delete_all), null: false
      add :status, :string, null: false
      add :rating, :integer
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:user_books, [:user_id])
    create index(:user_books, [:book_id])
    create unique_index(:user_books, [:user_id, :book_id])
  end
end
