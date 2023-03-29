defmodule PrinterSupervisor do
  use Supervisor

  def create([lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests, pool_id]) do
    IO.puts("\n-> Printer Supervisor #{pool_id} started\n")
    Supervisor.start_link(__MODULE__, [lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests, pool_id])
  end

  def init([lambda, min_sleep_time, max_sleep_time, nr_of_workers, nr_of_requests, pool_id]) do
    children = [
      %{
        id: "load_balancer#{pool_id}",
        start: {LoadBalancer, :start, [nr_of_workers]},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      },
      %{
        id: "workers_manager#{pool_id}",
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
        id: "tweet_redacter#{pool_id}",
        start: {TweetRedacter, :start, []},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      },
      %{
        id: "sentiment_score_comp#{pool_id}",
        start: {SentimentScoreComp, :start, []},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      },
      %{
        id: "engagement_ratio_comp#{pool_id}",
        start: {EngagementRatioComp, :start, []},
        restart: :transient,
        shutdown: 5000,
        type: :worker,
        max_restarts: 99999
      }
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 99999)
  end

  def get_worker(pid, id) do
    child = Supervisor.which_children(pid)
    elem(Enum.find(child, fn {worker_id, _pid, _type, _module} -> worker_id == id end), 1)
  end

  def display_workers(pid) do
    Enum.reverse(Supervisor.which_children(pid))
  end

  def print(pid, i, tweet) do
    load_balancer_pid = get_worker(pid, "load_balancer#{i}")
    workers_manager_pid = get_worker(pid, "workers_manager#{i}")
    tweet_redacter_pid = get_worker(pid, "tweet_redacter#{i}")
    sentiment_score_comp_pid = get_worker(pid, "sentiment_score_comp#{i}")
    engagement_ratio_comp_pid = get_worker(pid, "engagement_ratio_comp#{i}")
    printer_ids = LoadBalancer.acquire_printer(load_balancer_pid, workers_manager_pid, pid)
    printer_pids = Enum.map(printer_ids, fn printer_id -> get_worker(pid, printer_id) end)
    printer_pid = hd(printer_pids)
    Printer.print(printer_pid, {printer_pid, tweet, load_balancer_pid, tweet_redacter_pid, sentiment_score_comp_pid, engagement_ratio_comp_pid})
  end

  def create_new_worker(pid, state, load_balancer_pid) do
    i = LoadBalancer.check_state(load_balancer_pid)
    Supervisor.start_child(pid, %{
      id: i,
      start: {Printer, :start, [[state.lambda, state.min_sleep_time, state.max_sleep_time, i]]},
      restart: :transient,
      shutdown: 5000,
      type: :worker,
      max_restarts: 99999
    })
    LoadBalancer.update_state(load_balancer_pid, i)
  end

  def remove_worker(pid, load_balancer_pid) do
    id = LoadBalancer.get_id(load_balancer_pid)
    printer_pid = get_worker(pid, id)
    Process.exit(printer_pid, :shutdown)
    IO.puts("-> Printer #{id} has been terminated")
    LoadBalancer.remove_from_state(load_balancer_pid, id)
  end
end
