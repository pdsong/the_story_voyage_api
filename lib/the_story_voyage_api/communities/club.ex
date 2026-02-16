defmodule TheStoryVoyageApi.Communities.Club do
  use Ecto.Schema
  import Ecto.Changeset

  alias TheStoryVoyageApi.Accounts.User
  alias TheStoryVoyageApi.Communities.{ClubMember, ClubThread}

  schema "clubs" do
    field :name, :string
    field :description, :string
    field :is_private, :boolean, default: false

    belongs_to :owner, User
    has_many :members, ClubMember
    has_many :threads, ClubThread

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(club, attrs) do
    club
    |> cast(attrs, [:name, :description, :is_private, :owner_id])
    |> validate_required([:name, :description, :is_private, :owner_id])
  end
end
