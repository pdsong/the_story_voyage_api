defmodule TheStoryVoyageApi.Repo.Migrations.CreateBookContentWarnings do
  use Ecto.Migration

  def change do
    create table(:book_content_warnings) do
      add :book_id, references(:books, on_delete: :delete_all), null: false
      add :content_warning_id, references(:content_warnings, on_delete: :delete_all), null: false
      add :reported_by_user_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:book_content_warnings, [
             :book_id,
             :content_warning_id,
             :reported_by_user_id
           ])

    create index(:book_content_warnings, [:content_warning_id])
  end
end
