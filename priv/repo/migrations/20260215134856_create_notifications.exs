defmodule TheStoryVoyageApi.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :recipient_id, references(:users, on_delete: :delete_all), null: false
      add :actor_id, references(:users, on_delete: :nilify_all)
      add :type, :string, null: false
      add :data, :map, default: %{}
      add :read_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:recipient_id])
    create index(:notifications, [:recipient_id, :inserted_at])
    # For unread queries
    create index(:notifications, [:recipient_id, :read_at])
  end
end
