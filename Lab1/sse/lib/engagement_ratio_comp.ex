defmodule EngagementRatioComp do
  use GenServer

  def start do
    IO.puts("-> Engagement Ratio Calculator started\n")
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:compute, tweet}, _from, state) do
    if Map.get(tweet, :followers) != 0 do
      engagement_ratio = (Map.get(tweet, :favorites) + Map.get(tweet, :retweets)) / Map.get(tweet, :followers)
      {:reply, engagement_ratio, state}
    else
      engagement_ratio = 0.0
      {:reply, engagement_ratio, state}
    end
  end

  def compute(engagement_ratio_comp_pid, tweet) do
    GenServer.call(engagement_ratio_comp_pid, {:compute, tweet})
  end
end
