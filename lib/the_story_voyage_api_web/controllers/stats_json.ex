defmodule TheStoryVoyageApiWeb.StatsJSON do
  @doc """
  Renders overview statistics.
  """
  def show(%{stats: stats}) do
    %{data: stats}
  end

  @doc """
  Renders year statistics.
  """
  def year(%{stats: stats}) do
    %{data: stats}
  end

  @doc """
  Renders distribution statistics.
  """
  def distribution(%{distribution: distribution}) do
    %{data: distribution}
  end
end
