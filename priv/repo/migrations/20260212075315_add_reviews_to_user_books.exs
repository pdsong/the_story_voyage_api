defmodule TheStoryVoyageApi.Repo.Migrations.AddReviewsToUserBooks do
  use Ecto.Migration

  def change do
    alter table(:user_books) do
      add :review_title, :string
      add :review_content, :text
    end
  end
end
