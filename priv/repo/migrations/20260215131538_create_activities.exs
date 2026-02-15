defmodule TheStoryVoyageApi.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :type, :string, null: false
      add :data, :map
      add :book_id, references(:books, on_delete: :nilify_all)

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:activities, [:user_id])
    create index(:activities, [:inserted_at])
    create index(:activities, [:book_id])
  end
end
