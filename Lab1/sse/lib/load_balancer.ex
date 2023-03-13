defmodule LoadBalancer do
  use GenServer

  def start(nr) do
    IO.puts("-> Load Balancer started\n")
    GenServer.start_link(__MODULE__, Map.new(1..nr, fn count -> {count, 0} end), name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:acquire_printer, _from, state) do
    id = Enum.min_by(state, fn {_key, value} -> value end) |> elem(0)
    state = Map.update(state, id, 1, &(&1 + 1))
    {:reply, id, state}
  end

  def handle_cast({:release_printer, id, tweet}, state) do
    case tweet do
      :kill ->
        state = Map.update(state, id, 1, fn _value -> 0 end)
        {:noreply, state}
      _ ->
        {:noreply, state}
    end
  end

  def acquire_printer do
    GenServer.call(__MODULE__, :acquire_printer)
  end

  def release_worker(id, tweet) do
    GenServer.cast(__MODULE__, {:release_printer, id, tweet})
  end
end
