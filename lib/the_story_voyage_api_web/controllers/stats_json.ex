defmodule TheStoryVoyageApiWeb.StatsJSON do
  def show(%{stats: stats}) do
    %{data: stats}
  end
end
