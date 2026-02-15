defmodule TheStoryVoyageApi.Repo.Migrations.CreateFriendRequests do
  use Ecto.Migration

  def change do
    create table(:friend_requests) do
      add :sender_id, references(:users, on_delete: :delete_all), null: false
      add :receiver_id, references(:users, on_delete: :delete_all), null: false
      add :status, :string, default: "pending", null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:friend_requests, [:sender_id, :receiver_id])
    create index(:friend_requests, [:receiver_id])
    create index(:friend_requests, [:sender_id])
  end
end
