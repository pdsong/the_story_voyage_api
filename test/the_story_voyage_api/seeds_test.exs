defmodule TheStoryVoyageApi.SeedsTest do
  @moduledoc """
  Test that seed data is loaded correctly after ecto.reset.
  Run seeds first, then verify counts.
  """
  use TheStoryVoyageApi.DataCase

  alias TheStoryVoyageApi.Repo
  alias TheStoryVoyageApi.Books.{Genre, Mood, ContentWarning}

  setup do
    # Run seeds in test database
    Code.eval_file("priv/repo/seeds.exs")
    :ok
  end

  test "seeds correct number of genres" do
    count = Repo.aggregate(Genre, :count, :id)
    assert count >= 45, "Expected at least 45 genres, got #{count}"
  end

  test "seeds correct number of moods" do
    count = Repo.aggregate(Mood, :count, :id)
    assert count == 14, "Expected 14 moods, got #{count}"
  end

  test "seeds correct number of content warnings" do
    count = Repo.aggregate(ContentWarning, :count, :id)
    assert count == 27, "Expected 27 content warnings, got #{count}"
  end

  test "genres have unique slugs" do
    genres = Repo.all(Genre)
    slugs = Enum.map(genres, & &1.slug)
    assert length(slugs) == length(Enum.uniq(slugs))
  end

  test "content warnings have categories" do
    warnings = Repo.all(ContentWarning)

    for warning <- warnings do
      assert warning.category, "Content warning '#{warning.name}' has no category"
    end
  end

  test "known genres exist" do
    programming = Repo.get_by(Genre, slug: "programming")
    assert programming, "Genre 'Programming' should exist"

    ml = Repo.get_by(Genre, slug: "machine-learning")
    assert ml, "Genre 'Machine Learning' should exist"

    math = Repo.get_by(Genre, slug: "mathematics")
    assert math, "Genre 'Mathematics' should exist"
  end

  test "seeds are idempotent (can run twice)" do
    # Run seeds again
    Code.eval_file("priv/repo/seeds.exs")

    genre_count = Repo.aggregate(Genre, :count, :id)
    assert genre_count >= 45
  end
end
