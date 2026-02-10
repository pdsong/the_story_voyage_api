defmodule TheStoryVoyageApi.Repo do
  use Ecto.Repo,
    otp_app: :the_story_voyage_api,
    adapter: Ecto.Adapters.SQLite3
end
