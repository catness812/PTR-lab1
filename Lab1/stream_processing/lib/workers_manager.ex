defmodule WorkersManager do
  use GenServer

  def start([lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests]) do
    IO.puts("-> Workers Manager started\n")
    GenServer.start_link(__MODULE__, [lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests])
  end

  def init([lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests]) do
    {:ok, %{lambda: lambda, min_sleep_time: min_sleep_time, max_sleep_time: max_sleep_time, nr_of_workers: nr_of_workers, nr_of_requests: nr_of_requests}}
  end

  def handle_cast({:analyze_count, nr, count, pid, load_balancer_pid}, state) do
    avg = count / nr
    if avg > state.nr_of_requests do
      PrinterSupervisor.create_new_worker(pid, state, load_balancer_pid)
    else
      if (nr > state.nr_of_workers && avg < state.nr_of_requests*0.75) do
        PrinterSupervisor.remove_worker(pid, load_balancer_pid)
      end
    end
    {:noreply, state}
  end

  def analyze_count(workers_manager_pid, nr, count, pid, load_balancer_pid) do
    GenServer.cast(workers_manager_pid, {:analyze_count, nr, count, pid, load_balancer_pid})
  end
end
