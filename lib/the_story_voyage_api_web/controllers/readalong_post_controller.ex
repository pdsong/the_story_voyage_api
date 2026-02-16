defmodule TheStoryVoyageApiWeb.ReadalongPostController do
  use TheStoryVoyageApiWeb, :controller

  alias TheStoryVoyageApi.Communities
  alias TheStoryVoyageApi.Communities.ReadalongPost

  action_fallback TheStoryVoyageApiWeb.FallbackController

  def index(conn, %{"section_id" => section_id}) do
    # In a real app we might verify if the section is part of a readalong the user can see?
    # For now, public readalongs imply public posts (timestamps permitting).
    posts = Communities.list_readalong_posts(section_id)
    render(conn, :index, posts: posts)
  end

  def create(conn, %{"section_id" => section_id, "post" => post_params}) do
    user = conn.assigns.current_user

    with {:ok, %ReadalongPost{} = post} <-
           Communities.create_readalong_post(user, section_id, post_params) do
      conn
      |> put_status(:created)
      |> render(:show, post: post)
    end
  end
end
