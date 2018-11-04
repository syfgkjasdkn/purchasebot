defmodule TGBotTest do
  use ExUnit.Case
  doctest TGBot

  test "greets the world" do
    assert TGBot.hello() == :world
  end
end
