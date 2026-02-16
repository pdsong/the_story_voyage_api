defmodule TheStoryVoyageApiWeb.ClubController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Communities
  alias TheStoryVoyageApi.Communities.Club

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, _params) do
    clubs = Communities.list_public_clubs()
    render(conn, :index, clubs: clubs)
  end

  def create(conn, %{"club" => club_params}) do
    user = conn.assigns.current_user

    with {:ok, %Club{} = club} <- Communities.create_club(user, club_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/clubs/#{club}")
      |> render(:show, club: club)
    end
  end

  def show(conn, %{"id" => id}) do
    club = Communities.get_club!(id)
    # Start: MVP just listing threads if member?
    # Or separate endpoint?
    # Let's include basic threads in show or separate?
    # Requirement: Show club details.
    render(conn, :show, club: club)
  end

  def join(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with {:ok, _member} <- Communities.join_club(user, id) do
      conn
      |> put_status(:created)
      |> json(%{message: "Joined successfully request sent"})
    end
  end

  def list_threads(conn, %{"id" => id}) do
    threads = Communities.list_club_threads(id)
    render(conn, :index_threads, threads: threads)
  end

  def create_thread(conn, %{"id" => id, "thread" => thread_params}) do
    user = conn.assigns.current_user

    with {:ok, thread} <- Communities.create_thread(user, id, thread_params) do
      conn
      |> put_status(:created)
      |> render(:show_thread, thread: thread)
    end
  end

  def vote_thread(conn, %{"thread_id" => thread_id}) do
    user = conn.assigns.current_user

    with {:ok, :voted} <- Communities.vote_thread(user, thread_id) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Voted successfully"})
    end
  end
end
