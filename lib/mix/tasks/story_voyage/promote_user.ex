defmodule Mix.Tasks.StoryVoyage.PromoteUser do
  @moduledoc """
  Promotes a user to a specific role (admin or librarian).

  ## Usage

      mix story_voyage.promote_user <email> <role>

  ## Examples

      mix story_voyage.promote_user songpeidong@gmail.com admin
      mix story_voyage.promote_user librarian@example.com librarian
  """
  use Mix.Task
  alias TheStoryVoyageApi.Accounts

  @shortdoc "Promotes a user to a specific role"
  def run([email, role]) when role in ["admin", "librarian", "user"] do
    Mix.Task.run("app.start")

    case Accounts.get_user_by_email(email) do
      nil ->
        Mix.shell().error("User with email #{email} not found.")

      user ->
        case Accounts.update_user(user, %{role: role}) do
          {:ok, _user} ->
            Mix.shell().info("Successfully promoted #{email} to #{role}.")

          {:error, changeset} ->
            Mix.shell().error("Failed to update user: #{inspect(changeset.errors)}")
        end
    end
  end

  def run(_) do
    Mix.shell().error(
      "Usage: mix story_voyage.promote_user <email> <role (admin|librarian|user)>"
    )
  end
end
