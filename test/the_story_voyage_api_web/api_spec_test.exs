defmodule TheStoryVoyageApiWeb.ApiSpecTest do
  use TheStoryVoyageApiWeb.ConnCase

  test "GET /api/openapi returns valid JSON spec", %{conn: conn} do
    conn = get(conn, "/api/openapi")
    assert conn.status == 200
    assert json = json_response(conn, 200)
    assert json["openapi"] == "3.0.0"
    assert json["info"]["title"] == "The Story Voyage API"
  end

  test "GET /api/swagger returns HTML", %{conn: conn} do
    conn = get(conn, "/api/swagger")
    assert conn.status == 200
    assert html_response(conn, 200) =~ "swagger-ui"
  end
end
