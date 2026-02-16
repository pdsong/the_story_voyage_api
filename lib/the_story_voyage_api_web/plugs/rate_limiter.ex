defmodule TheStoryVoyageApiWeb.Plugs.RateLimiter do
  use GenServer

  # Configuration
  @params %{
    # requests
    limit: 100,
    # milliseconds (60s)
    window: 60_000
  }

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def check_rate(key) do
    GenServer.call(__MODULE__, {:check_rate, key})
  end

  # Server Callbacks

  @impl true
  def init(_) do
    # Schedule cleanup every window
    schedule_cleanup()
    {:ok, %{}}
  end

  @impl true
  def handle_call({:check_rate, key}, _from, state) do
    count = Map.get(state, key, 0)

    if count >= @params.limit do
      {:reply, {:error, :rate_limited}, state}
    else
      new_state = Map.put(state, key, count + 1)
      {:reply, {:ok, count + 1}, new_state}
    end
  end

  @impl true
  def handle_info(:cleanup, _state) do
    schedule_cleanup()
    # Simple fixed window: clear everything.
    # For robust production, a sliding window or bucket is better, but this meets requirements.
    {:noreply, %{}}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @params.window)
  end
end
