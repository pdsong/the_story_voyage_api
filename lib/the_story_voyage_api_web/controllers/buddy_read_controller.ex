defmodule TheStoryVoyageApiWeb.BuddyReadController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Communities
  alias TheStoryVoyageApi.Communities.BuddyRead

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, _params) do
    user = conn.assigns.current_user
    buddy_reads = Communities.list_visible_buddy_reads(user)
    render(conn, :index, buddy_reads: buddy_reads)
  end

  def create(conn, %{"buddy_read" => buddy_read_params}) do
    user = conn.assigns.current_user

    with {:ok, %BuddyRead{} = buddy_read} <-
           Communities.create_buddy_read(user, buddy_read_params) do
      # Preload data for view
      buddy_read = Communities.get_buddy_read!(buddy_read.id)

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/buddy_reads/#{buddy_read}")
      |> render(:show, buddy_read: buddy_read)
    end
  end

  def show(conn, %{"id" => id}) do
    buddy_read = Communities.get_buddy_read!(id)
    render(conn, :show, buddy_read: buddy_read)
  end

  def join(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with {:ok, _participant} <- Communities.join_buddy_read(user, id) do
      conn
      |> put_status(:created)
      |> json(%{message: "Joined buddy read successfully"})
    end
  end
end
