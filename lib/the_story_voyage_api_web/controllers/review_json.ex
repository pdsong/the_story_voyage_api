defmodule TheStoryVoyageApiWeb.ReviewJSON do
  alias TheStoryVoyageApi.Accounts.UserBook

  def index(%{reviews: reviews}) do
    %{data: for(review <- reviews, do: data(review))}
  end

  def data(%UserBook{} = review) do
    %{
      id: review.id,
      rating: review.rating,
      title: review.review_title,
      content: review.review_content,
      user: %{
        id: review.user.id,
        username: review.user.username
      },
      updated_at: review.updated_at
    }
  end
end
