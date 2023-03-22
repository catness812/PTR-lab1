defmodule WorkersManager do
  use GenServer

  def start([lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests]) do
    IO.puts("-> Workers Manager started\n")
    GenServer.start_link(__MODULE__, [lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests], name: __MODULE__)
  end

  def init([lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests]) do
    {:ok, %{lambda: lambda, min_sleep_time: min_sleep_time, max_sleep_time: max_sleep_time, nr_of_workers: nr_of_workers, nr_of_requests: nr_of_requests}}
  end

  def handle_cast({:analyze_count, nr, count}, state) do
    avg = count / nr
    if avg > state.nr_of_requests do
      PrinterSupervisor.create_new_worker(state)
    else
      if (nr > state.nr_of_workers && avg < state.nr_of_requests*0.75) do
        PrinterSupervisor.remove_worker
      end
    end
    {:noreply, state}
  end

  def analyze_count(nr, count) do
    GenServer.cast(__MODULE__, {:analyze_count, nr, count})
  end
end
