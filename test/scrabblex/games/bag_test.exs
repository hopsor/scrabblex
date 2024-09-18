defmodule Scrabblex.Games.BagTest do
  use ExUnit.Case

  alias Scrabblex.Games.{Bag, Player, Tile}

  describe "new/1" do
    test "returns a list of structs with as many items as the distribution has available" do
      {:ok, bag} = Bag.new("FISE-2")
      assert length(bag) == 100
    end
  end

  describe "init_hands/2" do
    test "returns as many hands as players are provided" do
      {:ok, bag} = Bag.new("FISE-2")
      players = [%Player{}, %Player{}]

      assert {:ok, [_, _], _remaining} = Bag.init_hands(bag, players)
    end

    test "returns a bag with the remaining tiles" do
      {:ok, bag} = Bag.new("FISE-2")
      players = [%Player{}, %Player{}]

      {:ok, _hands, remaining} = Bag.init_hands(bag, players)

      assert length(remaining) == 100 - 7 * 2
    end
  end

  describe "draw_tiles/3 with strict: false" do
    test "when the bag has enough it returns a tuple with the demand and the remainder" do
      bag = [%Tile{id: "1"}, %Tile{id: "2"}, %Tile{id: "3"}, %Tile{id: "4"}, %Tile{id: "5"}]

      assert {:ok, [_, _], [_, _, _]} = Bag.draw_tiles(bag, 2)
    end

    test "when the bag hasn't enough tiles it returns the remainder " do
      bag = [%Tile{id: "1"}, %Tile{id: "2"}]

      assert {:ok, [_, _], []} = Bag.draw_tiles(bag, 3)
    end

    test "when the bag is empty it returns two empty lists" do
      bag = []

      assert {:ok, [], []} = Bag.draw_tiles(bag, 2)
    end
  end

  describe "draw_tiles/3 with strict: true" do
    test "when the bag has enough it returns a tuple with the demand and the remainder" do
      bag = [%Tile{id: "1"}, %Tile{id: "2"}, %Tile{id: "3"}, %Tile{id: "4"}, %Tile{id: "5"}]

      assert {:ok, [_, _], [_, _, _]} = Bag.draw_tiles(bag, 2, strict: true)
    end

    test "when the bag hasn't enough tiles it returns the remainder " do
      bag = [%Tile{id: "1"}, %Tile{id: "2"}]

      assert {:error, :demand_exceeded} = Bag.draw_tiles(bag, 3, strict: true)
    end

    test "when the bag is empty it returns two empty lists" do
      bag = []

      assert {:error, :demand_exceeded} = Bag.draw_tiles(bag, 2, strict: true)
    end
  end
end
