defmodule TheStoryVoyageApi.Repo.Migrations.CreateUserFollows do
  use Ecto.Migration

  def change do
    create table(:user_follows) do
      add :follower_id, references(:users, on_delete: :delete_all), null: false
      add :followed_id, references(:users, on_delete: :delete_all), null: false
      add :is_friend, :boolean, default: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:user_follows, [:follower_id, :followed_id])
    create index(:user_follows, [:followed_id])
  end
end
