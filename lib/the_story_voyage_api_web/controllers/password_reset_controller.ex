defmodule TheStoryVoyageApiWeb.PasswordResetController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Accounts
  alias TheStoryVoyageApi.Accounts.UserNotifier

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def create(conn, %{"email" => email}) do
    if user = Accounts.get_user_by_email(email) do
      {:ok, user} = Accounts.create_reset_token(user)
      UserNotifier.deliver_reset_password_instructions(user, user.reset_password_token)
    end

    # Always return success to prevent email enumeration
    conn
    |> put_status(:accepted)
    |> json(%{
      message:
        "If your email is in our system, you will receive instructions to reset your password."
    })
  end

  def update(conn, %{"token" => token, "password" => password}) do
    with user when not is_nil(user) <- Accounts.get_user_by_reset_token(token),
         true <- token_valid?(user),
         {:ok, _user} <- Accounts.reset_password(user, %{password: password}) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Password reset successfully."})
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{detail: "Invalid or expired token"}})

      false ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{detail: "Token expired"}})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  defp token_valid?(user) do
    # Token valid for 1 hour
    expire_limit = DateTime.utc_now() |> DateTime.add(-3600, :second)
    DateTime.compare(user.reset_password_sent_at, expire_limit) == :gt
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
