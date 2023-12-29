defmodule TavernTest do
  use ExUnit.Case
  doctest Tavern

  test "greets the world" do
    assert Tavern.hello() == :world
  end
end
