defmodule WandaTest do
  use ExUnit.Case
  doctest Wanda

  test "greets the world" do
    assert Wanda.hello() == :world
  end
end
