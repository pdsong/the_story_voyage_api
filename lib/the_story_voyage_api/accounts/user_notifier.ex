defmodule TheStoryVoyageApi.Accounts.UserNotifier do
  import Swoosh.Email

  alias TheStoryVoyageApi.Mailer

  def deliver_correction_instructions(user) do
    # Example logic for future implementation
    {:ok, %{to: to_string(user.email)}}
  end

  def deliver_reset_password_instructions(user, token) do
    deliver(user.email, "Reset your password", """
    Hi #{user.username},

    You can reset your password by copying this token:

    #{token}

    If you didn't request this change, please ignore this.
    """)
  end

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"TheStoryVoyage", "contact@thestoryvoyage.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end
end
