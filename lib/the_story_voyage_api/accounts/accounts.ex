defmodule TheStoryVoyageApi.Accounts do
  @moduledoc """
  The Accounts context — manages users, follows, blocks, and authentication.
  """
  import Ecto.Query
  alias TheStoryVoyageApi.Repo
  alias TheStoryVoyageApi.Accounts.{User, UserBook}

  @doc "Returns a user by ID."
  def get_user(id), do: Repo.get(User, id)

  @doc "Returns a user by ID or raises."
  def get_user!(id), do: Repo.get!(User, id)

  @doc "Returns a user by email."
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc "Returns a user by username."
  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  @doc "Authenticates a user by email and password."
  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Bcrypt.no_user_verify()
        {:error, :unauthorized}
    end
  end

  @doc "Creates a new user with registration changeset (hashes password)."
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc "Creates a new user with the given attributes (admin/internal)."
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a user."
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc "Gets a user by reset token."
  def get_user_by_reset_token(token) do
    Repo.get_by(User, reset_password_token: token)
  end

  @doc "Updates a user's profile."
  def update_user_profile(%User{} = user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  @doc "Gets a public user profile by username. Respects privacy settings (implementation details in controller usually, but here we just fetch)."
  def get_public_user(username) do
    Repo.get_by(User, username: username)
  end

  @doc "Generates a reset token for the user."
  def create_reset_token(user) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

    user
    |> User.changeset(%{
      reset_password_token: token,
      reset_password_sent_at: DateTime.utc_now()
    })
    |> Repo.update()
  end

  @doc "Resets the user password."
  def reset_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> User.changeset(%{
      reset_password_token: nil,
      reset_password_sent_at: nil
    })
    |> Repo.update()
  end

  @doc "Lists all users (for admin)."
  def list_users do
    Repo.all(User)
  end

  # ========== User Books (Reading Status) ==========

  def list_user_books(%User{} = user, params \\ %{}) do
    query =
      from ub in UserBook,
        where: ub.user_id == ^user.id,
        preload: [book: [:authors, :genres, :moods], tags: []]

    status = params["status"]
    query = if status, do: where(query, [ub], ub.status == ^status), else: query

    tag = params["tag"]

    query =
      if tag do
        from ub in query,
          join: t in assoc(ub, :tags),
          where: t.tag_name == ^tag
      else
        query
      end

    Repo.all(query)
  end

  def get_user_book(%User{} = user, book_id) do
    Repo.get_by(UserBook, user_id: user.id, book_id: book_id)
  end

  def track_book(%User{} = user, book_id, attrs) do
    {action, changeset} =
      case get_user_book(user, book_id) do
        nil ->
          {:insert, %UserBook{user_id: user.id, book_id: book_id} |> UserBook.changeset(attrs)}

        existing ->
          {:update, existing |> UserBook.changeset(attrs)}
      end

    result =
      case action do
        :insert -> Repo.insert(changeset)
        :update -> Repo.update(changeset)
      end

    case result do
      {:ok, user_book} ->
        recalculate_book_rating(book_id)
        maybe_create_activity(user, user_book, changeset)
        {:ok, user_book}

      error ->
        error
    end
  end

  defp maybe_create_activity(user, user_book, changeset) do
    # Avoid circular dependency alias if possible, or alias here
    alias TheStoryVoyageApi.Social

    # Check for status change
    if status = Ecto.Changeset.get_change(changeset, :status) do
      case status do
        "reading" -> Social.create_activity(user, "started_book", %{book_id: user_book.book_id})
        "read" -> Social.create_activity(user, "finished_book", %{book_id: user_book.book_id})
        _ -> :ok
      end
    end

    # Check for rating
    if rating = Ecto.Changeset.get_change(changeset, :rating) do
      Social.create_activity(user, "rated_book", %{book_id: user_book.book_id, rating: rating})
    end

    # Check for review
    if Ecto.Changeset.get_change(changeset, :review_content) do
      # Only if content is non-empty? Validation constraint handles logic but here implies content changed.
      Social.create_activity(user, "reviewed_book", %{book_id: user_book.book_id})
    end
  end

  def untrack_book(%User{} = user, book_id) do
    case get_user_book(user, book_id) do
      nil ->
        {:error, :not_found}

      existing ->
        res = Repo.delete(existing)
        recalculate_book_rating(book_id)
        res
    end
  end

  def recalculate_book_rating(book_id) do
    query =
      from ub in UserBook,
        where: ub.book_id == ^book_id and not is_nil(ub.rating),
        select: {count(ub.id), avg(ub.rating)}

    {count, average} = Repo.one(query)

    # If count is 0, average is nil, default to 0.0
    average = average || 0.0
    count = count || 0

    # We need to use Books context or direct repo update.
    # To avoid circular dependency if Books uses Accounts, we use Repo directly or a Books function.
    # But Books context is higher level? Usually Accounts -> Books dependency is fine if Books doesn't depend on Accounts.
    # But UserBook belongs_to Book, so Accounts depends on Books schema.
    # Let's use Repo.update_all or get and update.
    import Ecto.Query

    from(b in TheStoryVoyageApi.Books.Book, where: b.id == ^book_id)
    |> Repo.update_all(set: [average_rating: average, ratings_count: count])
  end

  def list_reviews_for_book(book_id, _params \\ %{}) do
    query =
      from ub in UserBook,
        where: ub.book_id == ^book_id,
        where: not is_nil(ub.review_content),
        preload: [:user],
        order_by: [desc: ub.updated_at]

    Repo.all(query)
  end
end
