defmodule Scrabblex.Games.BagBuilderTest do
  use ExUnit.Case

  alias Scrabblex.Games.{BagBuilder, Player}

  describe "build/1" do
    test "returns a list of structs with as many items as the distribution has available" do
      {:ok, bag} = BagBuilder.build("fise2")
      assert length(bag) == 100
    end
  end

  describe "init_hands/2" do
    test "returns as many hands as players are provided" do
      {:ok, bag} = BagBuilder.build("fise2")
      players = [%Player{}, %Player{}]

      assert {:ok, [_, _], _remaining} = BagBuilder.init_hands(bag, players)
    end

    test "returns a bag with remaining tiles" do
      {:ok, bag} = BagBuilder.build("fise2")
      players = [%Player{}, %Player{}]

      {:ok, _hands, remaining} = BagBuilder.init_hands(bag, players)

      assert length(remaining) == 100 - 7 * 2
    end
  end
end
