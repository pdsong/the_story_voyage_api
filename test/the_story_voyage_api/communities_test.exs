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
end
