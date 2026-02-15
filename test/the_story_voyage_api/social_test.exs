defmodule TheStoryVoyageApi.SocialTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Social
  import TheStoryVoyageApi.AccountsFixtures

  describe "follows" do
    test "follow_user/2 creates a follow" do
      user1 = user_fixture()
      user2 = user_fixture()
      assert {:ok, _follow} = Social.follow_user(user1, user2)
      assert Social.following?(user1.id, user2.id)
    end

    test "cannot follow self" do
      user = user_fixture()
      assert {:error, :cannot_follow_self} = Social.follow_user(user, user)
    end

    test "unfollow_user/2 removes follow" do
      user1 = user_fixture()
      user2 = user_fixture()
      Social.follow_user(user1, user2)
      assert {:ok, :unfollowed} = Social.unfollow_user(user1, user2)
      refute Social.following?(user1.id, user2.id)
    end
  end

  describe "blocks" do
    test "block_user/2 blocks and auto-unfollows" do
      user1 = user_fixture()
      user2 = user_fixture()

      Social.follow_user(user1, user2)
      Social.follow_user(user2, user1)

      assert {:ok, _} = Social.block_user(user1, user2)

      assert Social.blocking?(user1.id, user2.id)
      refute Social.following?(user1.id, user2.id)
      refute Social.following?(user2.id, user1.id)
    end

    test "cannot block self" do
      user = user_fixture()
      assert {:error, :cannot_block_self} = Social.block_user(user, user)
    end
  end

  describe "friends" do
    test "friend request flow: send -> accept" do
      sender = user_fixture()
      receiver = user_fixture()

      # Send
      assert {:ok, request} = Social.send_friend_request(sender, receiver)
      assert request.status == "pending"

      # Accept
      assert {:ok, _} = Social.accept_friend_request(request.id, receiver)

      # Verify auto-follow
      assert Social.following?(sender.id, receiver.id)
      assert Social.following?(receiver.id, sender.id)

      # Verify list friends
      friends = Social.list_friends(sender)
      assert length(friends) == 1
      assert hd(friends).id == receiver.id
    end

    test "cannot friend blocked user" do
      sender = user_fixture()
      receiver = user_fixture()
      Social.block_user(receiver, sender)

      assert {:error, :blocked} = Social.send_friend_request(sender, receiver)
    end
  end

  describe "activities" do
    import TheStoryVoyageApi.BooksFixtures

    test "create_activity/3 creates an activity" do
      user = user_fixture()
      book = book_fixture()
      assert {:ok, activity} = Social.create_activity(user, "started_book", %{book_id: book.id})
      assert activity.type == "started_book"
      assert activity.data.book_id == book.id
    end

    test "list_feed/2 lists activities from followed users" do
      user = user_fixture()
      followed_user = user_fixture()
      non_followed_user = user_fixture()

      Social.follow_user(user, followed_user)

      book = book_fixture()

      {:ok, activity1} =
        Social.create_activity(followed_user, "started_book", %{book_id: book.id})

      {:ok, _activity2} =
        Social.create_activity(non_followed_user, "started_book", %{book_id: book.id})

      feed = Social.list_feed(user)
      assert length(feed) == 1
      assert hd(feed).id == activity1.id
    end

    test "list_feed/2 orders by inserted_at desc" do
      user = user_fixture()
      followed_user = user_fixture()
      Social.follow_user(user, followed_user)

      book = book_fixture()

      {:ok, _} = Social.create_activity(followed_user, "started_book", %{book_id: book.id})
      # Ensure timestamp diff > 1s
      :timer.sleep(1100)

      {:ok, activity2} =
        Social.create_activity(followed_user, "finished_book", %{book_id: book.id})

      feed = Social.list_feed(user)
      assert length(feed) == 2
      assert hd(feed).id == activity2.id
    end
  end
end
