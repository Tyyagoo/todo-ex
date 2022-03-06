defmodule TodoExTest do
  use ExUnit.Case
  doctest TodoEx

  test "greets the world" do
    assert TodoEx.hello() == :world
  end
end
