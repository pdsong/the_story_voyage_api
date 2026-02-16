defmodule TheStoryVoyageApiWeb.ReadalongController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Communities
  alias TheStoryVoyageApi.Communities.Readalong

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, _params) do
    readalongs = Communities.list_readalongs()
    render(conn, :index, readalongs: readalongs)
  end

  def create(conn, %{"readalong" => readalong_params}) do
    user = conn.assigns.current_user

    with {:ok, %Readalong{} = readalong} <- Communities.create_readalong(user, readalong_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", ~p"/api/v1/readalongs/#{readalong}")
      |> render(:show, readalong: readalong)
    end
  end

  def show(conn, %{"id" => id}) do
    readalong = Communities.get_readalong!(id)
    render(conn, :show, readalong: readalong)
  end

  def join(conn, %{"readalong_id" => id}) do
    user = conn.assigns.current_user

    with {:ok, _participant} <- Communities.join_readalong(user, id) do
      conn
      |> put_status(:created)
      |> json(%{data: %{message: "Joined successfully"}})
    end
  end
end
