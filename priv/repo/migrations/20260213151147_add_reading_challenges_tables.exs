defmodule TheStoryVoyageApi.Repo.Migrations.AddReadingChallengesTables do
  use Ecto.Migration

  def change do
    # 1. Reading Goals
    create table(:reading_goals) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :year, :integer, null: false
      add :target, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:reading_goals, [:user_id, :year])

    # 2. Challenges
    create table(:challenges) do
      add :title, :string, null: false
      add :description, :text
      add :start_date, :date
      add :end_date, :date
      # official, user_created, etc.
      add :type, :string, default: "official", null: false

      timestamps(type: :utc_datetime)
    end

    # 3. Challenge Prompts
    create table(:challenge_prompts) do
      add :challenge_id, references(:challenges, on_delete: :delete_all), null: false
      add :description, :string, null: false
      add :order_index, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:challenge_prompts, [:challenge_id])

    # 4. User Challenges (Participations)
    create table(:user_challenges) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :challenge_id, references(:challenges, on_delete: :delete_all), null: false
      # joined, completed
      add :status, :string, default: "joined"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_challenges, [:user_id, :challenge_id])

    # 5. User Challenge Entries (Linking books to prompts)
    create table(:user_challenge_entries) do
      add :user_challenge_id, references(:user_challenges, on_delete: :delete_all), null: false
      add :prompt_id, references(:challenge_prompts, on_delete: :delete_all), null: false
      # If user untracks book, entry becomes invalid/empty? Or nilify.
      add :user_book_id, references(:user_books, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_challenge_entries, [:user_challenge_id, :prompt_id])
  end
end
