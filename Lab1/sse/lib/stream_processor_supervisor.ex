defmodule StreamProcessorSupervisor do
  use Supervisor

  def start([lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests, nr_of_pools]) do
    {:ok, supervisor} = Supervisor.start_link(__MODULE__, [lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests, nr_of_pools], name: __MODULE__)
    IO.puts("\n-> Stream Processor Supervisor started with PID #{inspect supervisor}")
  end

  def init([lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests, nr_of_pools]) do
    children = [
      %{
        id: :reader1,
        start: {Reader1, :start, [nr_of_pools]},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      },
      %{
        id: :reader2,
        start: {Reader2, :start, [nr_of_pools]},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      },
      %{
        id: :hashtag_printer,
        start: {HashtagPrinter, :start, []},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      },
      %{
        id: :user_engagement_ratio_comp,
        start: {UserEngagementRatioComp, :start, []},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      }
    ] ++ Enum.map(1..nr_of_pools, fn i ->
      %{
        id: i,
        start: {PrinterSupervisor, :create, [[lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests, i]]},
        restart: :transient,
        shutdown: 5000,
        type: :supervisor,
        max_restarts: 99999
      }
    end)

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 99999)
  end

  def get_worker(id) do
    child = Supervisor.which_children(__MODULE__)
    elem(Enum.find(child, fn {worker_id, _pid, _type, _module} -> worker_id == id end), 1)
  end

  def display_workers do
    Enum.reverse(Supervisor.which_children(__MODULE__))
  end

  def print(nr_of_pools, msg) do
    nr_of_pools = nr_of_pools |> hd()
    for i <- 1..nr_of_pools do
      pid = get_worker(i)
      PrinterSupervisor.print(pid, i, msg)
    end
  end
end
