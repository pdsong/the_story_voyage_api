defmodule TheStoryVoyageApi.CommunitiesReadalongTest do
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Communities
  alias TheStoryVoyageApi.Communities.Readalong
  import TheStoryVoyageApi.CommunitiesFixtures
  import TheStoryVoyageApi.AccountsFixtures
  import TheStoryVoyageApi.BooksFixtures

  describe "readalongs" do
    @invalid_attrs %{title: nil, start_date: nil, book_id: nil}

    test "list_readalongs/0 returns all readalongs" do
      owner = user_fixture()
      book = book_fixture()
      readalong = readalong_fixture(owner_id: owner.id, book_id: book.id)
      assert Communities.list_readalongs() |> Enum.map(& &1.id) == [readalong.id]
    end

    test "get_readalong!/1 returns the readalong with given id" do
      owner = user_fixture()
      book = book_fixture()
      readalong = readalong_fixture(owner_id: owner.id, book_id: book.id)
      assert Communities.get_readalong!(readalong.id).id == readalong.id
    end

    test "create_readalong/2 with valid data creates a readalong and joins owner" do
      owner = user_fixture()
      book = book_fixture()

      valid_attrs = %{
        title: "Some Title",
        description: "some description",
        start_date: ~D[2026-04-01],
        book_id: book.id,
        sections: [
          %{
            title: "Week 1",
            start_chapter: 1,
            end_chapter: 5,
            unlock_date: ~U[2026-04-01 10:00:00Z]
          },
          %{
            title: "Week 2",
            start_chapter: 6,
            end_chapter: 10,
            unlock_date: ~U[2026-04-08 10:00:00Z]
          }
        ]
      }

      assert {:ok, %Readalong{} = readalong} = Communities.create_readalong(owner, valid_attrs)
      assert readalong.title == "Some Title"
      assert readalong.owner_id == owner.id
      assert Communities.is_readalong_participant?(owner.id, readalong.id)

      # Check sections created
      full_readalong = Communities.get_readalong!(readalong.id)
      assert length(full_readalong.sections) == 2
    end

    test "create_readalong/2 with invalid data returns error changeset" do
      owner = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Communities.create_readalong(owner, @invalid_attrs)
    end
  end

  describe "readalong posts" do
    test "create_readalong_post/3 fails if section is locked" do
      owner = user_fixture()
      book = book_fixture()
      # 1 hour in future
      future_date = DateTime.add(DateTime.utc_now(), 3600, :second)

      {:ok, readalong} =
        Communities.create_readalong(owner, %{
          title: "Locked Event",
          start_date: ~D[2026-04-01],
          book_id: book.id,
          sections: [%{title: "Locked", unlock_date: future_date}]
        })

      section = Communities.get_readalong!(readalong.id).sections |> hd()

      # Creation should fail with :locked
      assert {:error, :locked} =
               Communities.create_readalong_post(owner, section.id, %{content: "Spoiler!"})
    end

    test "create_readalong_post/3 succeeds if section is unlocked" do
      owner = user_fixture()
      book = book_fixture()
      # 1 hour ago
      past_date = DateTime.add(DateTime.utc_now(), -3600, :second)

      {:ok, readalong} =
        Communities.create_readalong(owner, %{
          title: "Unlocked Event",
          start_date: ~D[2026-04-01],
          book_id: book.id,
          sections: [%{title: "Unlocked", unlock_date: past_date}]
        })

      section = Communities.get_readalong!(readalong.id).sections |> hd()

      assert {:ok, _post} =
               Communities.create_readalong_post(owner, section.id, %{content: "Safe discussion"})
    end
  end
end
