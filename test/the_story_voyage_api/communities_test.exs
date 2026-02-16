defmodule TheStoryVoyageApi.CommunitiesTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Communities
  import TheStoryVoyageApi.AccountsFixtures

  describe "clubs" do
    test "create_club/2 creates club and adds owner as admin" do
      user = user_fixture()

      assert {:ok, club} =
               Communities.create_club(user, %{
                 name: "SciFi Club",
                 description: "Best club",
                 is_private: false
               })

      assert club.owner_id == user.id
      assert Communities.is_member?(user.id, club.id)
    end

    test "join_club/2 adds member (public)" do
      owner = user_fixture()

      {:ok, club} =
        Communities.create_club(owner, %{
          name: "Public Club",
          description: "Open",
          is_private: false
        })

      user = user_fixture()
      assert {:ok, member} = Communities.join_club(user, club.id)
      assert member.status == "joined"
    end

    test "join_club/2 adds member (private)" do
      owner = user_fixture()

      {:ok, club} =
        Communities.create_club(owner, %{
          name: "Private Club",
          description: "Closed",
          is_private: true
        })

      user = user_fixture()
      assert {:ok, member} = Communities.join_club(user, club.id)
      assert member.status == "pending"
    end
  end

  describe "threads" do
    test "create_thread/3 allows member to post" do
      owner = user_fixture()

      {:ok, club} =
        Communities.create_club(owner, %{
          name: "Book Club",
          description: "Desc",
          is_private: false
        })

      assert {:ok, thread} =
               Communities.create_thread(owner, club.id, %{
                 title: "Next Book?",
                 content: "Let's read Dune",
                 vote_count: 0
               })

      assert thread.title == "Next Book?"
    end

    test "create_thread/3 forbids non-member" do
      owner = user_fixture()

      {:ok, club} =
        Communities.create_club(owner, %{
          name: "Book Club",
          description: "Desc",
          is_private: false
        })

      outsider = user_fixture()

      assert {:error, :forbidden} =
               Communities.create_thread(outsider, club.id, %{title: "Spam", content: "Spam"})
    end

    test "vote_thread/2 increments count and enforces unique vote" do
      owner = user_fixture()

      {:ok, club} =
        Communities.create_club(owner, %{
          name: "Book Club",
          description: "Desc",
          is_private: false
        })

      {:ok, thread} =
        Communities.create_thread(owner, club.id, %{
          title: "Poll",
          content: "Vote now",
          vote_count: 0
        })

      # Vote
      assert {:ok, :voted} = Communities.vote_thread(owner, thread.id)

      thread = Communities.get_club_thread!(thread.id)
      assert thread.vote_count == 1

      # Duplicate Vote
      assert {:error, changeset} = Communities.vote_thread(owner, thread.id)
      # Unique constraint error
      assert changeset.errors[:thread_id]
    end
  end

  describe "buddy_reads" do
    alias TheStoryVoyageApi.Communities.BuddyRead
    import TheStoryVoyageApi.CommunitiesFixtures
    import TheStoryVoyageApi.BooksFixtures

    test "create_buddy_read/2 creates read and adds creator as participant" do
      user = user_fixture()
      book = book_fixture()

      assert {:ok, buddy_read} =
               Communities.create_buddy_read(user, %{
                 start_date: ~D[2026-02-15],
                 book_id: book.id
               })

      assert buddy_read.creator_id == user.id
      assert buddy_read.status == "active"

      # Check participant
      participants = Communities.list_buddy_read_participants()
      assert length(participants) == 1
      assert hd(participants).user_id == user.id
    end

    test "join_buddy_read/2 allows joining if capacity < 9" do
      creator = user_fixture()
      buddy_read = buddy_read_fixture(creator: creator)

      # Creator is already participant (1)

      new_user = user_fixture()
      # Simulate friendship or openness?
      # Current logic: not (is_creator or is_friend) -> forbidden.
      # So we need to be friend.
      # Follow back to make it friend?
      TheStoryVoyageApi.Social.follow_user(creator, new_user)
      # Wait, is_friend? checks if user follows creator?
      # Logic: is_friend?(user.id, buddy_read.creator_id)
      # Does user follow creator with is_friend=true?
      # We need mutual follow to be is_friend=true.

      # Set up friendship
      TheStoryVoyageApi.Repo.insert!(%TheStoryVoyageApi.Social.UserFollow{
        follower_id: new_user.id,
        followed_id: creator.id,
        is_friend: true
      })

      assert {:ok, _part} = Communities.join_buddy_read(new_user, buddy_read.id)
    end

    test "join_buddy_read/2 forbidden if not friend" do
      creator = user_fixture()
      buddy_read = buddy_read_fixture(creator: creator)
      stranger = user_fixture()

      assert {:error, :forbidden} = Communities.join_buddy_read(stranger, buddy_read.id)
    end

    test "list_visible_buddy_reads/1 returns participated or friend's reads" do
      creator = user_fixture()
      friend = user_fixture()
      stranger = user_fixture()

      # Friendship
      TheStoryVoyageApi.Repo.insert!(%TheStoryVoyageApi.Social.UserFollow{
        follower_id: friend.id,
        followed_id: creator.id,
        is_friend: true
      })

      br = buddy_read_fixture(creator: creator)

      # Creator sees it
      assert Communities.list_visible_buddy_reads(creator) |> length() == 1

      # Friend sees it
      assert Communities.list_visible_buddy_reads(friend) |> length() == 1

      # Stranger sees nothing
      assert Communities.list_visible_buddy_reads(stranger) == []
    end
  end
end
