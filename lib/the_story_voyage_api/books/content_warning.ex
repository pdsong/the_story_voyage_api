defmodule TheStoryVoyageApi.Books.ContentWarning do
  @moduledoc """
  Schema for content warning tags (e.g. violence, mental health topics).
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "content_warnings" do
    field :name, :string
    field :slug, :string
    field :category, :string
  end

  def changeset(content_warning, attrs) do
    content_warning
    |> cast(attrs, [:name, :slug, :category])
    |> validate_required([:name, :slug])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end
