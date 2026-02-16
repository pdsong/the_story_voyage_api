defmodule TheStoryVoyageApi.Communities.ReadalongPost do
  use Ecto.Schema
  import Ecto.Changeset

  alias TheStoryVoyageApi.Communities.ReadalongSection
  alias TheStoryVoyageApi.Accounts.User

  schema "readalong_posts" do
    field :content, :string
    belongs_to :section, ReadalongSection, foreign_key: :readalong_section_id
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content, :readalong_section_id, :user_id])
    |> validate_required([:content, :readalong_section_id, :user_id])
  end
end
