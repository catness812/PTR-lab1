defmodule Printer do
  use GenServer

  def start([lambda, min_sleep_time, max_sleep_time, id]) do
    IO.puts("-> Printer #{id} started\n")
    GenServer.start_link(__MODULE__, [lambda, min_sleep_time, max_sleep_time, id])
  end

  def init([lambda, min_sleep_time, max_sleep_time, id]) do
    {:ok, %{lambda: lambda, min_sleep_time: min_sleep_time, max_sleep_time: max_sleep_time, id: id}}
  end

  def handle_cast({pid, tweet}, state) do
    case tweet do
      :kill ->
        IO.puts("-> Printer #{state.id} has received a kill message. Restarting...")
        LoadBalancer.release_worker(state.id, tweet)
        Process.exit(pid, :normal)
        {:noreply, state}
      _ ->
        sleep_time = Statistics.Distributions.Poisson.rand(state.lambda) + state.min_sleep_time
        sleep_time = if sleep_time > state.max_sleep_time, do: state.max_sleep_time, else: sleep_time
        :timer.sleep(trunc(sleep_time))
        IO.puts("Tweet:\n#{tweet}\n")
        LoadBalancer.release_worker(state.id, tweet)
        {:noreply, state}
    end
  end

  def print(pid, {pid, tweet}) do
    GenServer.cast(pid, {pid, tweet})
  end
end
