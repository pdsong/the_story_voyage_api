defmodule TheStoryVoyageApiWeb.NotificationController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Notifications

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, params) do
    user = conn.assigns.current_user
    notifications = Notifications.list_notifications(user, params)
    render(conn, :index, notifications: notifications)
  end

  def mark_read(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    case Notifications.mark_as_read(id, user.id) do
      {:ok, notification} ->
        render(conn, :show, notification: notification)

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def mark_all_read(conn, _params) do
    user = conn.assigns.current_user
    Notifications.mark_all_as_read(user.id)
    send_resp(conn, 204, "")
  end
end
