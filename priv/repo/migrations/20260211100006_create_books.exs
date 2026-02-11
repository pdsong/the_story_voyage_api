defmodule TheStoryVoyageApi.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string, null: false
      add :original_title, :string
      add :description, :text
      add :pace, :string
      add :character_or_plot, :string
      add :average_rating, :float, default: 0.0
      add :ratings_count, :integer, default: 0
      add :first_published, :date
      add :series_id, references(:series, on_delete: :nilify_all)
      add :series_position, :float

      timestamps(type: :utc_datetime)
    end

    create index(:books, [:title])
    create index(:books, [:series_id])
  end
end
