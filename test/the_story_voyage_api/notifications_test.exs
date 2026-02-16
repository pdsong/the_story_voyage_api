defmodule TheStoryVoyageApi.NotificationsTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Notifications
  import TheStoryVoyageApi.AccountsFixtures

  describe "notifications" do
    test "create_notification/1 creates a notification" do
      user = user_fixture()
      actor = user_fixture()
      attrs = %{recipient_id: user.id, actor_id: actor.id, type: "new_follower"}

      assert {:ok, notification} = Notifications.create_notification(attrs)
      assert notification.type == "new_follower"
      assert notification.recipient_id == user.id
    end

    test "list_notifications/2 returns notifications for user" do
      user = user_fixture()

      notification =
        %{recipient_id: user.id, type: "new_follower"}
        |> Notifications.create_notification()
        |> elem(1)

      assert notifications = Notifications.list_notifications(user)
      assert length(notifications) == 1
      assert hd(notifications).id == notification.id
    end

    test "mark_as_read/1 marks as read" do
      user = user_fixture()

      {:ok, notification} =
        Notifications.create_notification(%{recipient_id: user.id, type: "new_follower"})

      assert is_nil(notification.read_at)
      assert {:ok, updated} = Notifications.mark_as_read(notification)
      assert updated.read_at
    end

    test "mark_all_as_read/1 marks all as read" do
      user = user_fixture()
      Notifications.create_notification(%{recipient_id: user.id, type: "new_follower"})
      Notifications.create_notification(%{recipient_id: user.id, type: "friend_request_received"})

      assert Notifications.unread_count(user.id) == 2

      Notifications.mark_all_as_read(user.id)

      assert Notifications.unread_count(user.id) == 0
    end
  end
end
