defmodule TheStoryVoyageApiWeb.Plugs.RateLimitPlug do
  import Plug.Conn
  alias TheStoryVoyageApiWeb.Plugs.RateLimiter

  def init(opts), do: opts

  def call(conn, _opts) do
    # Identify by IP. If behind proxy (e.g. Nginx/gigalixir), utilize x-forwarded-for logic
    # provided by Plug.Conn.remote_ip (needs proper config)
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()

    case RateLimiter.check_rate(ip) do
      {:ok, _count} ->
        conn

      {:error, :rate_limited} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(429, Jason.encode!(%{errors: %{detail: "Rate limit exceeded"}}))
        |> halt()
    end
  end
end
