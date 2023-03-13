defmodule PrinterSupervisor do
  use Supervisor

  def create([lambda, min_sleep_time, max_sleep_time, nr]) do
    {:ok, supervisor} = Supervisor.start_link(__MODULE__, [lambda, min_sleep_time, max_sleep_time, nr], name: __MODULE__)
    IO.puts("-> Printer Supervisor started with PID: #{inspect supervisor}\n")
  end

  def init([lambda, min_sleep_time, max_sleep_time, nr]) do
    children = [
      %{
        id: :load_balancer,
        start: {LoadBalancer, :start, [nr]},
        restart: :permanent,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      }
    ] ++ Enum.map(1..nr, fn i ->
      %{
        id: i,
        start: {Printer, :start, [[lambda, min_sleep_time, max_sleep_time, i]]},
        restart: :permanent,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      }
    end)

    children = children ++ [
      %{
        id: :hashtag_printer,
        start: {HashtagPrinter, :start, []},
        restart: :permanent,
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
    id = LoadBalancer.acquire_printer()
    pid = get_worker(id)
    Printer.print(pid, {pid, tweet})
  end
end
