defmodule TheStoryVoyageApi.Repo.Migrations.AddPagesToBooks do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :pages, :integer
    end
  end
end
