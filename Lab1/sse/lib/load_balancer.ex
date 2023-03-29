defmodule LoadBalancer do
  use GenServer

  def start(nr) do
    IO.puts("-> Load Balancer started\n")
    GenServer.start_link(__MODULE__, Map.new(1..nr, fn count -> {count, 0} end))
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:acquire_printer, load_balancer_pid, workers_manager_pid, pid}, _from, state) do
    sorted_state = Enum.sort_by(state, fn {_key, v} -> v end)
    ids = sorted_state |> Enum.take(3) |> Enum.map(&elem(&1, 0))
    nr = map_size(state)
    count = state |> Map.values() |> Enum.sum()
    WorkersManager.analyze_count(workers_manager_pid, nr, count, pid, load_balancer_pid)
    {:reply, ids, state}
  end

  def handle_call(:check_state, _from, state) do
    last_key = state |> Map.keys() |> Enum.max()
    next_key = last_key + 1
    {:reply, next_key, state}
  end

  def handle_call(:get_id, _from, state) do
    id = Enum.max_by(state, fn {_key, value} -> value end) |> elem(0)
    {:reply, id, state}
  end

  def handle_cast({:release_printer, id, tweet}, state) do
    case tweet do
      :kill ->
        state = Map.update(state, id, 1, fn _value -> 0 end)
        {:noreply, state}
      _ ->
        state = Map.update(state, id, 1, &(&1 + 1))
        {:noreply, state}
    end
  end

  def handle_cast({:update_state, id}, state) do
    state = state |> Map.put(id, 0)
    {:noreply, state}
  end

  def handle_cast({:remove_from_state, id}, state) do
    state = state |> Map.delete(id)
    {:noreply, state}
  end

  def acquire_printer(load_balancer_pid, workers_manager_pid, pid) do
    GenServer.call(load_balancer_pid, {:acquire_printer, load_balancer_pid, workers_manager_pid, pid})
  end

  def release_worker(load_balancer_pid, id, tweet) do
    GenServer.cast(load_balancer_pid, {:release_printer, id, tweet})
  end

  def check_state(load_balancer_pid) do
    GenServer.call(load_balancer_pid, :check_state)
  end

  def update_state(load_balancer_pid, id) do
    GenServer.cast(load_balancer_pid, {:update_state, id})
  end

  def get_id(load_balancer_pid) do
    GenServer.call(load_balancer_pid, :get_id)
  end

  def remove_from_state(load_balancer_pid, id) do
    GenServer.cast(load_balancer_pid, {:remove_from_state, id})
  end
end
