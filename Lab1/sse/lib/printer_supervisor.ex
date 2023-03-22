defmodule PrinterSupervisor do
  use Supervisor

  def create([lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests]) do
    {:ok, supervisor} = Supervisor.start_link(__MODULE__, [lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests], name: __MODULE__)
    IO.puts("-> Printer Supervisor started with PID: #{inspect supervisor}\n")
  end

  def init([lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests]) do
    children = [
      %{
        id: :load_balancer,
        start: {LoadBalancer, :start, [nr_of_workers]},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      },
      %{
        id: :workers_manager,
        start: {WorkersManager, :start, [[lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests]]},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      }
    ] ++ Enum.map(1..nr_of_workers, fn i ->
      %{
        id: i,
        start: {Printer, :start, [[lambda, min_sleep_time, max_sleep_time, i]]},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      }
    end)

    children = children ++ [
      %{
        id: :hashtag_printer,
        start: {HashtagPrinter, :start, []},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      }
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 99999)
  end

  def get_worker(id) do
    child = Supervisor.which_children(__MODULE__)
    elem(Enum.find(child, fn {worker_id, _pid, _type, _module} -> worker_id == id end), 1)
  end

  def display_workers do
    Enum.reverse(Supervisor.which_children(__MODULE__))
  end

  def print(tweet) do
    ids = LoadBalancer.acquire_printer()
    pids = Enum.map(ids, fn id -> get_worker(id) end)
    pid = hd(pids)
    Printer.print(pid, {pid, tweet})
  end

  def create_new_worker(state) do
    i = LoadBalancer.check_state
    Supervisor.start_child(__MODULE__, %{
      id: i,
      start: {Printer, :start, [[state.lambda, state.min_sleep_time, state.max_sleep_time, i]]},
      restart: :transient,
      shutdown: 5000,
      type: :worker,
      max_restarts: 99999
    })
    LoadBalancer.update_state(i)
  end

  def remove_worker do
    id = LoadBalancer.get_id
    pid = get_worker(id)
    Process.exit(pid, :shutdown)
    IO.puts("-> Printer #{id} has been terminated")
    LoadBalancer.remove_from_state(id)
  end
end
