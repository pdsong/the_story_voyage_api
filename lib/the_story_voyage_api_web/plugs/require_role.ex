defmodule TheStoryVoyageApiWeb.Plugs.RequireRole do
  import Plug.Conn
  import Phoenix.Controller

  def init(roles), do: roles

  def call(conn, roles) do
    user = conn.assigns[:current_user]

    if user && user.role in roles do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{errors: %{detail: "You do not have permission to perform this action."}})
      |> halt()
    end
  end
end
