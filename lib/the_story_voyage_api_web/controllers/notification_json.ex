defmodule TheStoryVoyageApiWeb.NotificationJSON do
  alias TheStoryVoyageApi.Notifications.Notification
  alias TheStoryVoyageApiWeb.UserJSON

  @doc """
  Renders a list of notifications.
  """
  def index(%{notifications: notifications}) do
    %{data: for(notification <- notifications, do: data(notification))}
  end

  @doc """
  Renders a single notification.
  """
  def show(%{notification: notification}) do
    %{data: data(notification)}
  end

  def data(%Notification{} = notification) do
    %{
      id: notification.id,
      type: notification.type,
      data: notification.data,
      read_at: notification.read_at,
      inserted_at: notification.inserted_at,
      actor_id: notification.actor_id,
      actor:
        if(Ecto.assoc_loaded?(notification.actor) && notification.actor,
          do: UserJSON.data(notification.actor),
          else: nil
        )
    }
  end
end
