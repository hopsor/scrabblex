defmodule Scrabblex.Games.MaptrixTest do
  use ExUnit.Case

  alias Scrabblex.Games.{BoardLayout, Maptrix, Match, Play, Player, Position, Tile}

  describe "from_match/1" do
    test "returns a map with all the tiles belonging to the plays already committed" do
      match = %Match{
        plays: [
          %Play{
            type: "play",
            tiles: [
              %Tile{value: "F", position: %Position{row: 0, column: 0}},
              %Tile{value: "O", position: %Position{row: 0, column: 1}},
              %Tile{value: "O", position: %Position{row: 0, column: 2}}
            ]
          },
          %Play{
            type: "play",
            tiles: [
              %Tile{value: "B", position: %Position{row: 1, column: 2}},
              %Tile{value: "A", position: %Position{row: 2, column: 2}},
              %Tile{value: "R", position: %Position{row: 3, column: 2}}
            ]
          }
        ]
      }

      assert Maptrix.from_match(match) == %{
               {0, 0} => %Tile{value: "F", position: %Position{row: 0, column: 0}},
               {0, 1} => %Tile{value: "O", position: %Position{row: 0, column: 1}},
               {0, 2} => %Tile{value: "O", position: %Position{row: 0, column: 2}},
               {1, 2} => %Tile{value: "B", position: %Position{row: 1, column: 2}},
               {2, 2} => %Tile{value: "A", position: %Position{row: 2, column: 2}},
               {3, 2} => %Tile{value: "R", position: %Position{row: 3, column: 2}}
             }
    end
  end

  describe "from_player/1" do
    test "returns a map with as many entries as tiles with positions has the player" do
      player = %Player{
        hand: [
          %Tile{value: "F", position: %Position{row: 0, column: 0}},
          %Tile{value: "O", position: %Position{row: 0, column: 1}},
          %Tile{value: "O", position: %Position{row: 0, column: 2}}
        ]
      }

      assert Maptrix.from_player(player) == %{
               {0, 0} => %Tile{value: "F", position: %Position{row: 0, column: 0}},
               {0, 1} => %Tile{value: "O", position: %Position{row: 0, column: 1}},
               {0, 2} => %Tile{value: "O", position: %Position{row: 0, column: 2}}
             }
    end
  end

  describe "from_board_layout/1" do
    test "returns a map with as many entries as boosters has the layout" do
      result = Maptrix.from_board_layout(BoardLayout.get())

      assert Map.keys(result) |> length() == 60
    end
  end
end
