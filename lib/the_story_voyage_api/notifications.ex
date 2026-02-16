defmodule TheStoryVoyageApi.Notifications do
  @moduledoc """
  The Notifications context.
  """
  import Ecto.Query, warn: false
  alias TheStoryVoyageApi.Repo
  alias TheStoryVoyageApi.Notifications.Notification
  alias TheStoryVoyageApi.Notifications.Notifier

  def list_notifications(user, params \\ %{}) do
    query =
      from n in Notification,
        where: n.recipient_id == ^user.id,
        order_by: [desc: n.inserted_at],
        preload: [:actor]

    # Pagination logic (Reuse from Social or Books or extract helper later)
    page = params["page"] || 1
    page_size = 20
    offset = (String.to_integer(to_string(page)) - 1) * page_size
    query = from n in query, limit: ^page_size, offset: ^offset

    Repo.all(query)
  end

  def create_notification(attrs) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, notification} ->
        # Trigger async email notification if needed
        Notifier.deliver_notification(notification)
        {:ok, notification}

      error ->
        error
    end
  end

  def mark_as_read(%Notification{} = notification) do
    notification
    |> Notification.changeset(%{read_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def mark_as_read(notification_id, user_id) do
    case Repo.get_by(Notification, id: notification_id, recipient_id: user_id) do
      nil -> {:error, :not_found}
      notification -> mark_as_read(notification)
    end
  end

  def mark_all_as_read(user_id) do
    from(n in Notification,
      where: n.recipient_id == ^user_id and is_nil(n.read_at)
    )
    |> Repo.update_all(set: [read_at: DateTime.utc_now(), updated_at: DateTime.utc_now()])

    {:ok, :all_marked_read}
  end

  def unread_count(user_id) do
    Repo.one(
      from n in Notification,
        where: n.recipient_id == ^user_id and is_nil(n.read_at),
        select: count(n.id)
    )
  end
end
