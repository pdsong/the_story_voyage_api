defmodule TheStoryVoyageApiWeb.ApiSpec do
  alias OpenApiSpex.{OpenApi, Info, Server, Components, SecurityScheme}

  @behaviour OpenApiSpex.OpenApi

  @impl OpenApiSpex.OpenApi
  def spec do
    %OpenApi{
      servers: [
        # Populate servers from config or default to localhost
        %Server{url: "http://localhost:4000", description: "Local Development"}
      ],
      info: %Info{
        title: "The Story Voyage API",
        version: "1.0",
        description: "API for The Story Voyage application."
      },
      # Paths are populated automatically from router/controllers
      paths: %{},
      components: %Components{
        securitySchemes: %{
          "authorization" => %SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT"
          }
        }
      },
      security: [
        %{"authorization" => []}
      ],
      tags: []
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
