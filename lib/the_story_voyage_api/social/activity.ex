defmodule TheStoryVoyageApi.Social.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activities" do
    field :type, :string
    field :data, :map

    belongs_to :user, TheStoryVoyageApi.Accounts.User
    belongs_to :book, TheStoryVoyageApi.Books.Book

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:user_id, :type, :data, :book_id])
    |> validate_required([:user_id, :type])
    |> validate_inclusion(:type, [
      "started_book",
      "finished_book",
      "rated_book",
      "reviewed_book",
      "joined_challenge"
    ])
  end
end
