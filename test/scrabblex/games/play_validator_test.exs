defmodule Scrabblex.Games.PlayValidatorTest do
  alias Scrabblex.Games.PlayValidator
  use ExUnit.Case

  alias Scrabblex.Games.{Match, Player, PlayValidator, Tile}
  alias Scrabblex.Games.Tile.Position

  describe "validate/2" do
    test "returns {:error, :center_not_found} when turn is 0 and none of the played tiles are on the center" do
      player = %Player{
        hand: [
          %Tile{score: 1, value: "F", position: %Position{row: 0, column: 0}},
          %Tile{score: 1, value: "O", position: %Position{row: 0, column: 1}},
          %Tile{score: 1, value: "O", position: %Position{row: 0, column: 2}},
          %Tile{score: 1, value: "B", position: %Position{row: 0, column: 3}},
          %Tile{score: 1, value: "A", position: %Position{row: 0, column: 4}},
          %Tile{score: 1, value: "R", position: %Position{row: 0, column: 5}},
          %Tile{score: 1, value: "Z", position: nil}
        ]
      }

      match = %Match{turn: 0, players: [player]}
      assert PlayValidator.validate(match, player) == {:error, :center_not_found}
    end

    test "returns {:error, :tiles_not_aligned} when played tiles aren't in line" do
      player = %Player{
        hand: [
          %Tile{score: 1, value: "F", position: %Position{row: 0, column: 0}},
          %Tile{score: 1, value: "O", position: %Position{row: 0, column: 1}},
          %Tile{score: 1, value: "O", position: %Position{row: 0, column: 2}},
          %Tile{score: 1, value: "B", position: %Position{row: 1, column: 3}},
          %Tile{score: 1, value: "A", position: %Position{row: 0, column: 4}},
          %Tile{score: 1, value: "R", position: %Position{row: 0, column: 5}},
          %Tile{score: 1, value: "Z", position: nil}
        ]
      }

      match = %Match{turn: 1, players: [player]}

      assert PlayValidator.validate(match, player) == {:error, :tiles_not_aligned}
    end
  end
end
