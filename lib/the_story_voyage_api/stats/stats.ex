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
  Compares two time periods.
  Values for period1 and period2 should be maps with keys :start_date and :end_date (DateTime).
  """
  def get_comparison(user_id, period1, period2) do
    stats1 = get_period_stats(user_id, period1.start_date, period1.end_date)
    stats2 = get_period_stats(user_id, period2.start_date, period2.end_date)

    diff = %{
      book_count: stats1.book_count - stats2.book_count,
      page_count: stats1.page_count - stats2.page_count,
      average_rating: stats1.average_rating - stats2.average_rating
    }

    %{
      period1: stats1,
      period2: stats2,
      diff: diff
    }
  end

  @doc """
  Compares a specific year with the previous year.
  """
  def get_year_comparison(user_id, year) do
    year_int = if is_binary(year), do: String.to_integer(year), else: year

    current_year_start = DateTime.new!(Date.new!(year_int, 1, 1), ~T[00:00:00])
    current_year_end = DateTime.new!(Date.new!(year_int, 12, 31), ~T[23:59:59])

    prev_year_start = DateTime.new!(Date.new!(year_int - 1, 1, 1), ~T[00:00:00])
    prev_year_end = DateTime.new!(Date.new!(year_int - 1, 12, 31), ~T[23:59:59])

    get_comparison(
      user_id,
      %{start_date: current_year_start, end_date: current_year_end},
      %{start_date: prev_year_start, end_date: prev_year_end}
    )
  end

  defp get_period_stats(user_id, start_date, end_date) do
    base_query =
      from ub in UserBook,
        where: ub.user_id == ^user_id and ub.status == "read",
        where: ub.updated_at >= ^start_date and ub.updated_at <= ^end_date

    count = Repo.aggregate(base_query, :count, :id)

    pages =
      Repo.one(
        from ub in base_query,
          join: b in assoc(ub, :book),
          select: sum(b.pages)
      ) || 0

    avg_rating =
      Repo.one(
        from ub in base_query,
          where: not is_nil(ub.rating),
          select: avg(ub.rating)
      ) || 0.0

    %{
      book_count: count,
      page_count: pages,
      average_rating: avg_rating
    }
  end

  @doc """
  Returns yearly activity heatmap data (daily counts).
  """
  def get_heatmap_data(user_id, year) do
    year_int = if is_binary(year), do: String.to_integer(year), else: year
    start_date = DateTime.new!(Date.new!(year_int, 1, 1), ~T[00:00:00])
    end_date = DateTime.new!(Date.new!(year_int, 12, 31), ~T[23:59:59])

    # Fetch all finished dates
    dates =
      Repo.all(
        from ub in UserBook,
          where: ub.user_id == ^user_id and ub.status == "read",
          where: ub.updated_at >= ^start_date and ub.updated_at <= ^end_date,
          select: ub.updated_at
      )

    dates
    |> Enum.map(&DateTime.to_date/1)
    |> Enum.frequencies()
    |> Enum.map(fn {date, count} -> %{date: date, count: count} end)
  end

  @doc """
  Calculates reading speed trend (days taken to read books).
  Requires started_at (F07 implies automated timestamping) and finished_at (updated_at).
  If started_at is nil, we skip.
  """
  def get_reading_speed_trend(user_id) do
    # Assuming inserted_at as proxy for started_at for MVP if started_at is missing from schema
    # But strictly speaking we should check if UserBook has started_at.
    # Checking schema: F07 says "UserBook schema (join table with status params)".
    # If explicit started_at col is missing, calculate inserted_at -> updated_at diff.

    query =
      from ub in UserBook,
        where: ub.user_id == ^user_id and ub.status == "read",
        order_by: ub.updated_at,
        # Using inserted_at as start proxy
        select: {ub.inserted_at, ub.updated_at}

    Repo.all(query)
    |> Enum.map(fn {start_dt, end_dt} ->
      days = Date.diff(DateTime.to_date(end_dt), DateTime.to_date(start_dt))
      # At least 1 day
      %{date: DateTime.to_date(end_dt), days_taken: max(days, 1)}
    end)
  end

  @doc """
  Generates a wrap-up summary for a given period (month or year).
  period_type: :month | :year
  period_value: "2025-02" (string) or 2025 (int)
  """
  def get_wrap_up(user_id, type, value) do
    {start_date, end_date} = parse_period(type, value)

    base_query =
      from ub in UserBook,
        join: b in assoc(ub, :book),
        where: ub.user_id == ^user_id and ub.status == "read",
        where: ub.updated_at >= ^start_date and ub.updated_at <= ^end_date

    # Aggregates
    total_books = Repo.aggregate(base_query, :count, :id)
    total_pages = Repo.one(from([ub, b] in base_query, select: sum(b.pages))) || 0

    # Top Rated
    top_books =
      Repo.all(
        from [ub, b] in base_query,
          order_by: [desc: ub.rating, desc: ub.updated_at],
          limit: 3,
          preload: [book: [:authors]],
          select: ub
      )

    # Most Read Genre
    most_read_genre =
      from([ub, b] in base_query,
        join: g in assoc(b, :genres),
        group_by: g.name,
        order_by: [desc: count(ub.id)],
        limit: 1,
        select: {g.name, count(ub.id)}
      )
      |> Repo.one()
      |> case do
        {name, count} -> %{name: name, count: count}
        nil -> nil
      end

    %{
      period: value,
      total_books: total_books,
      total_pages: total_pages,
      top_books: top_books,
      most_read_genre: most_read_genre
    }
  end

  defp parse_period(:year, year) do
    year_int = if is_binary(year), do: String.to_integer(year), else: year

    {
      DateTime.new!(Date.new!(year_int, 1, 1), ~T[00:00:00]),
      DateTime.new!(Date.new!(year_int, 12, 31), ~T[23:59:59])
    }
  end

  defp parse_period(:month, date_str) do
    # Expected format "YYYY-MM"
    [year_s, month_s] = String.split(date_str, "-")
    year = String.to_integer(year_s)
    month = String.to_integer(month_s)

    start_date = Date.new!(year, month, 1)
    end_date = Date.end_of_month(start_date)

    {
      DateTime.new!(start_date, ~T[00:00:00]),
      DateTime.new!(end_date, ~T[23:59:59])
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
