defmodule TheStoryVoyageApi.Repo.Migrations.FixUserBooksSchemaSqlite do
  use Ecto.Migration

  def up do
    alter table(:user_books) do
      add :rating_float, :float
      add :review_contains_spoilers, :boolean, default: false, null: false
    end

    # Copy data from integer column to float column
    execute "UPDATE user_books SET rating_float = CAST(rating AS REAL)"

    alter table(:user_books) do
      remove :rating
    end

    rename table(:user_books), :rating_float, to: :rating
  end

  def down do
    alter table(:user_books) do
      add :rating_int, :integer
      remove :review_contains_spoilers
    end

    execute "UPDATE user_books SET rating_int = CAST(rating AS INTEGER)"

    alter table(:user_books) do
      remove :rating
    end

    rename table(:user_books), :rating_int, to: :rating
  end
end
