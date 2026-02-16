defmodule TheStoryVoyageApiWeb.Schemas do
  alias OpenApiSpex.Schema

  defmodule UserRegister do
    require OpenApiSpex.Schema
    @behaviour OpenApiSpex.Schema

    @impl true
    def schema do
      %Schema{
        type: :object,
        properties: %{
          user: %Schema{
            type: :object,
            properties: %{
              email: %Schema{type: :string, format: :email},
              password: %Schema{type: :string},
              username: %Schema{type: :string}
            },
            required: [:email, :password, :username]
          }
        }
      }
    end
  end

  defmodule UserResponse do
    require OpenApiSpex.Schema
    @behaviour OpenApiSpex.Schema

    @impl true
    def schema do
      %Schema{
        type: :object,
        properties: %{
          data: %Schema{
            type: :object,
            properties: %{
              token: %Schema{type: :string},
              user: %Schema{
                type: :object,
                properties: %{
                  id: %Schema{type: :integer},
                  username: %Schema{type: :string},
                  email: %Schema{type: :string}
                }
              }
            }
          }
        }
      }
    end
  end

  defmodule BookResponse do
    require OpenApiSpex.Schema
    @behaviour OpenApiSpex.Schema

    @impl true
    def schema do
      %Schema{
        type: :object,
        properties: %{
          data: %Schema{
            type: :object,
            properties: %{
              id: %Schema{type: :integer},
              title: %Schema{type: :string},
              description: %Schema{type: :string},
              average_rating: %Schema{type: :number},
              authors: %Schema{
                type: :array,
                items: %Schema{
                  type: :object,
                  properties: %{
                    id: %Schema{type: :integer},
                    name: %Schema{type: :string}
                  }
                }
              }
            }
          }
        }
      }
    end
  end

  defmodule BookListResponse do
    require OpenApiSpex.Schema
    @behaviour OpenApiSpex.Schema

    @impl true
    def schema do
      %Schema{
        type: :object,
        properties: %{
          data: %Schema{
            type: :array,
            items: BookResponse
          }
        }
      }
    end
  end
end
