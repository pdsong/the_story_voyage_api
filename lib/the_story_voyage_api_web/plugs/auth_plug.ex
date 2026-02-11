defmodule TheStoryVoyageApiWeb.AuthPlug do
  @moduledoc """
  Plug to authenticate requests via JWT Bearer token.
  """
  import Plug.Conn
  alias TheStoryVoyageApi.{Token, Accounts}

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- Token.verify_token(token),
         user_id = claims["user_id"],
         user when not is_nil(user) <- Accounts.get_user(user_id) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{errors: %{detail: "Unauthorized"}})
        |> halt()
    end
  end
end
