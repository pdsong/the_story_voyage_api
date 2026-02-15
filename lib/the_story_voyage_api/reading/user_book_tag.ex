defmodule TheStoryVoyageApi.Reading.UserBookTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_book_tags" do
    belongs_to :user_book, TheStoryVoyageApi.Accounts.UserBook
    field :tag_name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_book_tag, attrs) do
    user_book_tag
    |> cast(attrs, [:user_book_id, :tag_name])
    |> validate_required([:user_book_id, :tag_name])
    |> validate_length(:tag_name, min: 1, max: 50)
    # Ensure tag is lowercase and trimmed? Or let database handle case sensitivity? Usually app layer.
    |> update_change(:tag_name, &String.trim/1)
    |> update_change(:tag_name, &String.downcase/1)
    |> unique_constraint([:user_book_id, :tag_name])
  end
end
