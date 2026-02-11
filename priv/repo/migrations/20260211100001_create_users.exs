defmodule TheStoryVoyageApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :display_name, :string
      add :bio, :text
      add :avatar_url, :string
      add :location, :string
      add :privacy_level, :string, default: "public"
      add :role, :string, default: "user"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end
end
