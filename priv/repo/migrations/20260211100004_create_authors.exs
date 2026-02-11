defmodule TheStoryVoyageApi.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :string, null: false
      add :bio, :text
      add :photo_url, :string
      add :born_date, :date
      add :nationality, :string

      timestamps(type: :utc_datetime)
    end

    create index(:authors, [:name])
  end
end
