defmodule Scrabblex.Games.PlayValidatorTest do
  alias Scrabblex.Games.PlayValidator
  use ExUnit.Case

  alias Scrabblex.Games.{Match, Play, Player, PlayValidator, Tile}
  alias Scrabblex.Games.Tile.Position
  alias Scrabblex.Games.Play.Word

  describe "validate/2 with an empty play" do
    setup do
      match = %Match{turn: 1, plays: [%Play{tiles: [], type: "skip"}]}
      {:ok, %{match: match}}
    end

    test "returns {:error, :empty_play} when there isn't any tile positioned", %{match: match} do
      player = %Player{
        hand: [
          %Tile{score: 1, value: "F", position: nil},
          %Tile{score: 1, value: "O", position: nil},
          %Tile{score: 1, value: "O", position: nil},
          %Tile{score: 1, value: "B", position: nil},
          %Tile{score: 1, value: "A", position: nil},
          %Tile{score: 1, value: "R", position: nil},
          %Tile{score: 1, value: "Z", position: nil}
        ]
      }

      assert PlayValidator.validate(match, player) == {:error, :empty_play}
    end
  end

  describe "validate/2 with empty board" do
    setup do
      match = %Match{turn: 1, plays: [%Play{tiles: [], type: "skip"}]}
      {:ok, %{match: match}}
    end

    test "returns {:error, :center_not_found} when tiles are aligned and contiguous but none of them are on the center",
         %{match: match} do
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

      assert PlayValidator.validate(match, player) == {:error, :center_not_found}
    end

    test "returns {:error, :contiguity_error} when tiles are aligned but not totally contiguous",
         %{match: match} do
      player = %Player{
        hand: [
          %Tile{score: 1, value: "F", position: %Position{row: 7, column: 5}},
          %Tile{score: 1, value: "O", position: %Position{row: 7, column: 6}},
          %Tile{score: 1, value: "O", position: %Position{row: 7, column: 7}},
          %Tile{score: 1, value: "B", position: %Position{row: 7, column: 9}},
          %Tile{score: 1, value: "A", position: %Position{row: 7, column: 10}},
          %Tile{score: 1, value: "R", position: %Position{row: 7, column: 11}},
          %Tile{score: 1, value: "Z", position: nil}
        ]
      }

      assert PlayValidator.validate(match, player) == {:error, :contiguity_error}
    end

    test "returns :ok when tiles are contiguous, horizontally aligned and cross the center", %{
      match: match
    } do
      player = %Player{
        hand: [
          %Tile{score: 1, value: "F", position: %Position{row: 7, column: 5}},
          %Tile{score: 1, value: "O", position: %Position{row: 7, column: 6}},
          %Tile{score: 1, value: "O", position: %Position{row: 7, column: 7}},
          %Tile{score: 1, value: "B", position: %Position{row: 7, column: 8}},
          %Tile{score: 1, value: "A", position: %Position{row: 7, column: 9}},
          %Tile{score: 1, value: "R", position: %Position{row: 7, column: 10}},
          %Tile{score: 1, value: "Z", position: nil}
        ]
      }

      assert PlayValidator.validate(match, player) == :ok
    end

    test "returns :ok when tiles are contiguous, vertically aligned and cross the center", %{
      match: match
    } do
      player = %Player{
        hand: [
          %Tile{score: 1, value: "F", position: %Position{row: 5, column: 7}},
          %Tile{score: 1, value: "O", position: %Position{row: 6, column: 7}},
          %Tile{score: 1, value: "O", position: %Position{row: 7, column: 7}},
          %Tile{score: 1, value: "B", position: %Position{row: 8, column: 7}},
          %Tile{score: 1, value: "A", position: %Position{row: 9, column: 7}},
          %Tile{score: 1, value: "R", position: %Position{row: 10, column: 7}},
          %Tile{score: 1, value: "Z", position: nil}
        ]
      }

      assert PlayValidator.validate(match, player) == :ok
    end
  end

  describe "validate/2 with filled board" do
    setup do
      match = %Match{
        turn: 1,
        plays: [
          %Play{
            tiles: [
              %Tile{value: "F", score: 1, position: %Position{row: 7, column: 6}},
              %Tile{value: "O", score: 1, position: %Position{row: 7, column: 7}},
              %Tile{value: "O", score: 1, position: %Position{row: 7, column: 8}}
            ],
            words: [%Word{value: "FOO", score: 3}],
            type: "play",
            turn: 0
          }
        ]
      }

      {:ok, %{match: match}}
    end

    test "returns {:error, :contiguity_error} when played tiles aren't contiguous to tiles from previous plays and board isn't empty",
         %{match: match} do
      player = %Player{
        hand: [
          %Tile{score: 1, value: "F", position: %Position{row: 1, column: 11}},
          %Tile{score: 1, value: "O", position: %Position{row: 2, column: 11}},
          %Tile{score: 1, value: "O", position: %Position{row: 3, column: 11}},
          %Tile{score: 1, value: "B", position: %Position{row: 4, column: 11}},
          %Tile{score: 1, value: "A", position: %Position{row: 5, column: 11}},
          %Tile{score: 1, value: "R", position: %Position{row: 6, column: 11}},
          %Tile{score: 1, value: "Z", position: nil}
        ]
      }

      assert PlayValidator.validate(match, player) == {:error, :contiguity_error}
    end

    test "returns {:error, :contiguity_error} when played tiles are partially contiguous to played ones",
         %{match: match} do
      player = %Player{
        hand: [
          %Tile{score: 1, value: "F", position: %Position{row: 1, column: 9}},
          %Tile{score: 1, value: "O", position: %Position{row: 2, column: 9}},
          %Tile{score: 1, value: "O", position: %Position{row: 4, column: 9}},
          %Tile{score: 1, value: "B", position: %Position{row: 5, column: 9}},
          %Tile{score: 1, value: "A", position: %Position{row: 6, column: 9}},
          %Tile{score: 1, value: "R", position: %Position{row: 7, column: 9}},
          %Tile{score: 1, value: "Z", position: nil}
        ]
      }

      assert PlayValidator.validate(match, player) == {:error, :contiguity_error}
    end

    test "returns :ok when played tiles are totally contiguous to played ones",
         %{match: match} do
      player = %Player{
        hand: [
          %Tile{score: 1, value: "F", position: %Position{row: 2, column: 9}},
          %Tile{score: 1, value: "O", position: %Position{row: 3, column: 9}},
          %Tile{score: 1, value: "O", position: %Position{row: 4, column: 9}},
          %Tile{score: 1, value: "B", position: %Position{row: 5, column: 9}},
          %Tile{score: 1, value: "A", position: %Position{row: 6, column: 9}},
          %Tile{score: 1, value: "R", position: %Position{row: 7, column: 9}},
          %Tile{score: 1, value: "Z", position: nil}
        ]
      }

      assert PlayValidator.validate(match, player) == :ok
    end

    test "returns :ok when played tiles are aligned, split in two words but the gaps are filled with already filled tiles from the board",
         %{match: match} do
      player = %Player{
        hand: [
          %Tile{score: 1, value: "F", position: %Position{row: 4, column: 7}},
          %Tile{score: 1, value: "O", position: %Position{row: 5, column: 7}},
          %Tile{score: 1, value: "O", position: %Position{row: 6, column: 7}},
          %Tile{score: 1, value: "B", position: %Position{row: 8, column: 7}},
          %Tile{score: 1, value: "A", position: %Position{row: 9, column: 7}},
          %Tile{score: 1, value: "R", position: %Position{row: 10, column: 7}},
          %Tile{score: 1, value: "Z", position: nil}
        ]
      }

      assert PlayValidator.validate(match, player) == :ok
    end
  end
end
