defmodule TheStoryVoyageApi.Repo.Migrations.CreateReadalongsTables do
  use Ecto.Migration

  def change do
    create table(:readalongs) do
      add :title, :string, null: false
      add :description, :text
      add :start_date, :date, null: false
      add :book_id, references(:books, on_delete: :nothing), null: false
      add :owner_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:readalongs, [:owner_id])
    create index(:readalongs, [:book_id])

    create table(:readalong_sections) do
      add :title, :string, null: false
      add :start_chapter, :integer
      add :end_chapter, :integer
      add :unlock_date, :utc_datetime, null: false
      add :readalong_id, references(:readalongs, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:readalong_sections, [:readalong_id])

    create table(:readalong_participants) do
      add :readalong_id, references(:readalongs, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:readalong_participants, [:readalong_id, :user_id])

    create table(:readalong_posts) do
      add :content, :text, null: false

      add :readalong_section_id, references(:readalong_sections, on_delete: :delete_all),
        null: false

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:readalong_posts, [:readalong_section_id])
    create index(:readalong_posts, [:user_id])
  end
end
