defmodule SseTest do
  use ExUnit.Case
  doctest Sse

  test "greets the world" do
    assert Sse.hello() == :world
  end
end
