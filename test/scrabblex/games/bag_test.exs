defmodule Scrabblex.Games.BagTest do
  use ExUnit.Case

  import Scrabblex.GamesFixtures
  alias Scrabblex.Games.BagDefinition
  alias Scrabblex.Games.{Bag, Lexicon, Player, Tile}

  setup_all do
    lexicon = %Lexicon{
      bag_definitions:
        Enum.map(
          bag_definitions_attrs(),
          &%BagDefinition{value: &1["value"], score: &1["score"], amount: &1["amount"]}
        )
    }

    {:ok, %{lexicon: lexicon}}
  end

  describe "new/1" do
    test "returns a list of structs with as many items as the distribution has available", %{
      lexicon: lexicon
    } do
      {:ok, bag} = Bag.new(lexicon)
      assert length(bag) == 104
    end
  end

  describe "init_hands/2" do
    test "returns as many hands as players are provided", %{lexicon: lexicon} do
      {:ok, bag} = Bag.new(lexicon)
      players = [%Player{}, %Player{}]

      assert {:ok, [_, _], _remaining} = Bag.init_hands(bag, players)
    end

    test "returns a bag with the remaining tiles", %{lexicon: lexicon} do
      {:ok, bag} = Bag.new(lexicon)
      players = [%Player{}, %Player{}]

      {:ok, _hands, remaining} = Bag.init_hands(bag, players)

      assert length(remaining) == 104 - 7 * 2
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

  describe "reinstate_tiles/2" do
    test "when there aren't wildcards it appends the given tiles to the bag" do
      bag = [%Tile{id: "1", value: "A", wildcard: false}]
      tiles = [%Tile{id: "1", value: "B", wildcard: false}]

      assert Bag.reinstate_tiles(bag, tiles) == {:ok, bag ++ tiles}
    end

    test "when there are wildcards it appends the given tiles and set values of wildcards to an empty string" do
      bag = [%Tile{id: "1", value: "A", wildcard: false}]
      tiles = [%Tile{id: "1", value: "B", wildcard: true}]

      assert Bag.reinstate_tiles(bag, tiles) ==
               {:ok, bag ++ [%Tile{id: "1", value: "", wildcard: true}]}
    end
  end
end
