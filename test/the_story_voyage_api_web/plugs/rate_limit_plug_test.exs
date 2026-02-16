defmodule TheStoryVoyageApiWeb.RateLimitPlugTest do
  use TheStoryVoyageApiWeb.ConnCase

  # We can't easily test the rate limiter in isolation without mocking or waiting constants,
  # but we can test the integration by hitting an endpoint repeatedly.
  # Assuming the limit is 100 per 60s as defined in the module.

  test "returns 429 when rate limit is exceeded", %{conn: conn} do
    # Identify a unique IP/key for this test to avoid conflicting with other tests/state
    # IP is mocked in connection

    # We'll need to hit it > 100 times.
    # To avoid slow tests, we might want to reset state or rely on a separate test environment config
    # but for now we'll just loop.

    # Ensure RateLimiter is running (it is part of application)

    # Use a specific IP for this test to avoid noise
    conn = %{conn | remote_ip: {127, 0, 0, 2}}

    # The limit is 100.
    for _ <- 1..100 do
      conn = %{conn | remote_ip: {127, 0, 0, 2}}
      conn = get(conn, ~p"/api/v1/books")
      assert conn.status != 429
    end

    # 101st request should fail
    conn = %{conn | remote_ip: {127, 0, 0, 2}}
    conn = get(conn, ~p"/api/v1/books")
    assert conn.status == 429
    assert json_response(conn, 429)["errors"]["detail"] == "Rate limit exceeded"
  end
end
