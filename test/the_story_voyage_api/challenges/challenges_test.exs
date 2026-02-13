defmodule TheStoryVoyageApi.ChallengesTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Challenges
  import TheStoryVoyageApi.ChallengesFixtures
  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  describe "reading_goals" do
    test "set_reading_goal/2 creates a goal" do
      user = user_fixture()
      assert {:ok, goal} = Challenges.set_reading_goal(user, %{year: 2025, target: 10})
      assert goal.year == 2025
      assert goal.target == 10
      assert goal.user_id == user.id
    end

    test "set_reading_goal/2 updates existing goal" do
      user = user_fixture()
      reading_goal_fixture(user, %{year: 2025, target: 10})

      assert {:ok, goal} = Challenges.set_reading_goal(user, %{year: 2025, target: 20})
      assert goal.target == 20
    end

    test "list_reading_goals/1 returns all goals for user" do
      user = user_fixture()
      reading_goal_fixture(user, %{year: 2025, target: 10})
      assert length(Challenges.list_reading_goals(user)) == 1
    end
  end

  describe "challenges" do
    test "list_challenges/0 returns all challenges" do
      challenge_fixture()
      assert length(Challenges.list_challenges()) == 1
    end

    test "join_challenge/2 joins a user" do
      user = user_fixture()
      challenge = challenge_fixture()

      assert {:ok, uc} = Challenges.join_challenge(user, challenge.id)
      assert uc.user_id == user.id
      assert uc.challenge_id == challenge.id
      assert uc.status == "joined"
    end

    test "add_entry/3 links a book to a prompt" do
      user = user_fixture()
      challenge = challenge_fixture()
      prompt = prompt_fixture(challenge)
      book = book_fixture()

      # Must join first
      Challenges.join_challenge(user, challenge.id)

      # Need a UserBook
      {:ok, ub} = TheStoryVoyageApi.Accounts.track_book(user, book.id, %{status: "read"})

      assert {:ok, entry} =
               Challenges.add_entry(user, challenge.id, %{
                 "prompt_id" => prompt.id,
                 "user_book_id" => ub.id
               })

      assert entry.prompt_id == prompt.id
      assert entry.user_book_id == ub.id
    end
  end
end
