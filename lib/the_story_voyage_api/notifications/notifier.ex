defmodule TheStoryVoyageApi.Notifications.Notifier do
  @moduledoc """
  Handles sending notifications (Email, etc).
  Mock implementation for now using Swoosh (implicitly, or just logging).
  In F04 we used Swoosh.
  """
  require Logger

  # Assuming we have a Mailer module from F04
  # alias TheStoryVoyageApi.Mailer
  # import Swoosh.Email

  def deliver_notification(notification) do
    # In a real app, we'd spawn a task or use Oban
    Task.start(fn ->
      send_email(notification)
    end)
  end

  defp send_email(notification) do
    # Load recipient email if not loaded (notification usually has recipient_id)
    # For now, just Log it to simulate email sending as per "Mock Email Sending" requirement in F04/F14

    Logger.info(
      " [Mock Email] Sending notification email to user #{notification.recipient_id} | Type: #{notification.type}"
    )

    # Example Swoosh construction:
    # email =
    #   new()
    #   |> to(user.email)
    #   |> from({"The Story Voyage", "noreply@storyvoyage.com"})
    #   |> subject(subject_for(notification))
    #   |> text_body(body_for(notification))

    # Mailer.deliver(email)
  end
end
