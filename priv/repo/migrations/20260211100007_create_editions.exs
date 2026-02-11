defmodule TheStoryVoyageApi.Repo.Migrations.CreateEditions do
  use Ecto.Migration

  def change do
    create table(:editions) do
      add :book_id, references(:books, on_delete: :delete_all), null: false
      add :isbn_10, :string
      add :isbn_13, :string
      add :format, :string
      add :page_count, :integer
      add :audio_duration_minutes, :integer
      add :publisher, :string
      add :publication_date, :date
      add :language, :string, default: "en"
      add :cover_image_url, :string

      timestamps(type: :utc_datetime)
    end

    create index(:editions, [:book_id])
    create index(:editions, [:isbn_13])
    create index(:editions, [:isbn_10])
  end
end
