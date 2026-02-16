defmodule TheStoryVoyageApi.Communities.ReadalongSection do
  use Ecto.Schema
  import Ecto.Changeset

  alias TheStoryVoyageApi.Communities.{Readalong, ReadalongPost}

  schema "readalong_sections" do
    field :title, :string
    field :start_chapter, :integer
    field :end_chapter, :integer
    field :unlock_date, :utc_datetime

    belongs_to :readalong, Readalong
    has_many :posts, ReadalongPost

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title, :start_chapter, :end_chapter, :unlock_date, :readalong_id])
    |> validate_required([:title, :unlock_date])
  end
end
