defmodule TheStoryVoyageApi.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias TheStoryVoyageApi.Repo
  alias TheStoryVoyageApi.Accounts.{UserBook}
  alias TheStoryVoyageApi.Books.{Book, Genre, Mood}

  @doc """
  Returns overview statistics for a user.
  """
  def get_overview(user_id) do
    # 1. Status Counts
    status_query =
      from ub in UserBook,
        where: ub.user_id == ^user_id,
        group_by: ub.status,
        select: {ub.status, count(ub.id)}

    status_counts = Repo.all(status_query) |> Map.new()

    # 2. Total Pages (only for "read" books)
    pages_query =
      from ub in UserBook,
        join: b in assoc(ub, :book),
        where: ub.user_id == ^user_id and ub.status == "read",
        select: sum(b.pages)

    # 3. Average Rating
    rating_query =
      from ub in UserBook,
        where: ub.user_id == ^user_id and not is_nil(ub.rating),
        select: avg(ub.rating)

    %{
      read_count: Map.get(status_counts, "read", 0),
      reading_count: Map.get(status_counts, "reading", 0),
      want_to_read_count: Map.get(status_counts, "want_to_read", 0),
      total_pages_read: Repo.one(pages_query) || 0,
      average_rating: Repo.one(rating_query) || 0.0
    }
  end

  @doc """
  Returns statistics for a specific year.
  """
  def get_year_stats(user_id, year) do
    year_int = if is_binary(year), do: String.to_integer(year), else: year
    start_date = DateTime.new!(Date.new!(year_int, 1, 1), ~T[00:00:00])
    end_date = DateTime.new!(Date.new!(year_int, 12, 31), ~T[23:59:59])

    # Filter books READ in this year (status == "read" and updated_at in range?
    # Ideally we use a 'finished_at' field but we don't have it yet in schema explicitly?
    # F07 said "status update to read sets finished_at".
    # Checking UserBook schema... I don't see `finished_at` in schema!
    # F07 doc says "updated_at" is used effectively or implied?
    # Wait, F07 design said "Status change automatically records timestamp (started_at, finished_at)".
    # Let me check UserBook schema again. It has `timestamps()`.
    # If `finished_at` is missing, I must use `updated_at` as a proxy for now, OR add the column.

    # Using `updated_at` for now as MVP proxy for "read date".

    base_query =
      from ub in UserBook,
        where: ub.user_id == ^user_id and ub.status == "read",
        where: ub.updated_at >= ^start_date and ub.updated_at <= ^end_date

    count = Repo.aggregate(base_query, :count, :id)

    pages_query =
      from ub in base_query,
        join: b in assoc(ub, :book),
        select: sum(b.pages)

    pages = Repo.one(pages_query) || 0

    rating_query =
      from ub in base_query,
        where: not is_nil(ub.rating),
        select: avg(ub.rating)

    avg_rating = Repo.one(rating_query) || 0.0

    # Monthly Timeline
    # Group by month. SQLite has specific date functions. Postgres has `date_trunc`.
    # Ecto might need fragment.
    # Simple approach: Fetch all dates and aggregate in Elixir for database agnosticism in MVP.
    timeline_data =
      from(ub in base_query, select: ub.updated_at)
      |> Repo.all()
      |> Enum.group_by(fn dt -> dt.month end)
      |> Enum.map(fn {month, list} -> {month, length(list)} end)
      |> Map.new()

    timeline = for m <- 1..12, do: %{month: m, count: Map.get(timeline_data, m, 0)}

    %{
      year: year_int,
      book_count: count,
      page_count: pages,
      average_rating: avg_rating,
      monthly_timeline: timeline
    }
  end

  @doc """
  Returns distribution of books by genre.
  Only considers 'read' books.
  """
  def get_genre_distribution(user_id) do
    query =
      from ub in UserBook,
        join: b in assoc(ub, :book),
        join: g in assoc(b, :genres),
        where: ub.user_id == ^user_id and ub.status == "read",
        group_by: g.name,
        select: {g.name, count(ub.id)}

    data = Repo.all(query)
    total = Enum.reduce(data, 0, fn {_, c}, acc -> acc + c end)

    Enum.map(data, fn {name, count} ->
      %{name: name, count: count, percentage: if(total > 0, do: count / total * 100, else: 0.0)}
    end)
    |> Enum.sort_by(& &1.count, :desc)
  end

  @doc """
  Returns distribution of books by mood.
  Only considers 'read' books.
  """
  def get_mood_distribution(user_id) do
    query =
      from ub in UserBook,
        join: b in assoc(ub, :book),
        join: m in assoc(b, :moods),
        where: ub.user_id == ^user_id and ub.status == "read",
        group_by: m.name,
        select: {m.name, count(ub.id)}

    data = Repo.all(query)
    total = Enum.reduce(data, 0, fn {_, c}, acc -> acc + c end)

    Enum.map(data, fn {name, count} ->
      %{name: name, count: count, percentage: if(total > 0, do: count / total * 100, else: 0.0)}
    end)
    |> Enum.sort_by(& &1.count, :desc)
  end
end
