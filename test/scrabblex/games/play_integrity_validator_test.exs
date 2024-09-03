defmodule Scrabblex.Games.PlayIntegrityValidatorTest do
  alias Scrabblex.Games.PlayIntegrityValidator
  use ExUnit.Case

  alias Scrabblex.Games.{PlayIntegrityValidator, Tile}
  alias Scrabblex.Games.Position

  describe "validate/2 with an empty play" do
    setup do
      existing_tiles = %{}
      {:ok, %{existing_tiles: existing_tiles}}
    end

    test "returns {:error, :empty_play} when there isn't any tile positioned", %{
      existing_tiles: existing_tiles
    } do
      tiles = []

      assert PlayIntegrityValidator.validate(existing_tiles, tiles) == {:error, :empty_play}
    end
  end

  describe "validate/2 with empty board" do
    setup do
      existing_tiles = %{}
      {:ok, %{existing_tiles: existing_tiles}}
    end

    test "returns {:error, :center_not_found} when tiles are aligned and contiguous but none of them are on the center",
         %{existing_tiles: existing_tiles} do
      tiles = [
        %Tile{score: 1, value: "F", position: %Position{row: 0, column: 0}},
        %Tile{score: 1, value: "O", position: %Position{row: 0, column: 1}},
        %Tile{score: 1, value: "O", position: %Position{row: 0, column: 2}},
        %Tile{score: 1, value: "B", position: %Position{row: 0, column: 3}},
        %Tile{score: 1, value: "A", position: %Position{row: 0, column: 4}},
        %Tile{score: 1, value: "R", position: %Position{row: 0, column: 5}}
      ]

      assert PlayIntegrityValidator.validate(existing_tiles, tiles) == {:error, :center_not_found}
    end

    test "returns {:error, :contiguity_error} when tiles are aligned but not totally contiguous",
         %{existing_tiles: existing_tiles} do
      tiles = [
        %Tile{score: 1, value: "F", position: %Position{row: 7, column: 5}},
        %Tile{score: 1, value: "O", position: %Position{row: 7, column: 6}},
        %Tile{score: 1, value: "O", position: %Position{row: 7, column: 7}},
        %Tile{score: 1, value: "B", position: %Position{row: 7, column: 9}},
        %Tile{score: 1, value: "A", position: %Position{row: 7, column: 10}},
        %Tile{score: 1, value: "R", position: %Position{row: 7, column: 11}}
      ]

      assert PlayIntegrityValidator.validate(existing_tiles, tiles) == {:error, :contiguity_error}
    end

    test "returns :ok when tiles are contiguous, horizontally aligned and cross the center", %{
      existing_tiles: existing_tiles
    } do
      tiles = [
        %Tile{score: 1, value: "F", position: %Position{row: 7, column: 5}},
        %Tile{score: 1, value: "O", position: %Position{row: 7, column: 6}},
        %Tile{score: 1, value: "O", position: %Position{row: 7, column: 7}},
        %Tile{score: 1, value: "B", position: %Position{row: 7, column: 8}},
        %Tile{score: 1, value: "A", position: %Position{row: 7, column: 9}},
        %Tile{score: 1, value: "R", position: %Position{row: 7, column: 10}}
      ]

      assert PlayIntegrityValidator.validate(existing_tiles, tiles) == {:ok, :horizontal}
    end

    test "returns :ok when tiles are contiguous, vertically aligned and cross the center", %{
      existing_tiles: existing_tiles
    } do
      tiles = [
        %Tile{score: 1, value: "F", position: %Position{row: 5, column: 7}},
        %Tile{score: 1, value: "O", position: %Position{row: 6, column: 7}},
        %Tile{score: 1, value: "O", position: %Position{row: 7, column: 7}},
        %Tile{score: 1, value: "B", position: %Position{row: 8, column: 7}},
        %Tile{score: 1, value: "A", position: %Position{row: 9, column: 7}},
        %Tile{score: 1, value: "R", position: %Position{row: 10, column: 7}}
      ]

      assert PlayIntegrityValidator.validate(existing_tiles, tiles) == {:ok, :vertical}
    end
  end

  describe "validate/2 with filled board" do
    setup do
      existing_tiles = %{
        {7, 6} => %Tile{value: "F", score: 1, position: %Position{row: 7, column: 6}},
        {7, 7} => %Tile{value: "O", score: 1, position: %Position{row: 7, column: 7}},
        {7, 8} => %Tile{value: "O", score: 1, position: %Position{row: 7, column: 8}}
      }

      {:ok, %{existing_tiles: existing_tiles}}
    end

    test "returns {:error, :contiguity_error} when played tiles aren't contiguous to tiles from previous plays and board isn't empty",
         %{existing_tiles: existing_tiles} do
      tiles = [
        %Tile{score: 1, value: "F", position: %Position{row: 1, column: 11}},
        %Tile{score: 1, value: "O", position: %Position{row: 2, column: 11}},
        %Tile{score: 1, value: "O", position: %Position{row: 3, column: 11}},
        %Tile{score: 1, value: "B", position: %Position{row: 4, column: 11}},
        %Tile{score: 1, value: "A", position: %Position{row: 5, column: 11}},
        %Tile{score: 1, value: "R", position: %Position{row: 6, column: 11}}
      ]

      assert PlayIntegrityValidator.validate(existing_tiles, tiles) == {:error, :contiguity_error}
    end

    test "returns {:error, :contiguity_error} when played tiles are partially contiguous to played ones",
         %{existing_tiles: existing_tiles} do
      tiles = [
        %Tile{score: 1, value: "F", position: %Position{row: 1, column: 9}},
        %Tile{score: 1, value: "O", position: %Position{row: 2, column: 9}},
        %Tile{score: 1, value: "O", position: %Position{row: 4, column: 9}},
        %Tile{score: 1, value: "B", position: %Position{row: 5, column: 9}},
        %Tile{score: 1, value: "A", position: %Position{row: 6, column: 9}},
        %Tile{score: 1, value: "R", position: %Position{row: 7, column: 9}}
      ]

      assert PlayIntegrityValidator.validate(existing_tiles, tiles) == {:error, :contiguity_error}
    end

    test "returns :ok when played tiles are totally contiguous to played ones",
         %{existing_tiles: existing_tiles} do
      tiles = [
        %Tile{score: 1, value: "F", position: %Position{row: 2, column: 9}},
        %Tile{score: 1, value: "O", position: %Position{row: 3, column: 9}},
        %Tile{score: 1, value: "O", position: %Position{row: 4, column: 9}},
        %Tile{score: 1, value: "B", position: %Position{row: 5, column: 9}},
        %Tile{score: 1, value: "A", position: %Position{row: 6, column: 9}},
        %Tile{score: 1, value: "R", position: %Position{row: 7, column: 9}}
      ]

      assert PlayIntegrityValidator.validate(existing_tiles, tiles) == {:ok, :vertical}
    end

    test "returns :ok when played tiles are aligned, split in two words but the gaps are filled with already filled tiles from the board",
         %{existing_tiles: existing_tiles} do
      tiles = [
        %Tile{score: 1, value: "F", position: %Position{row: 4, column: 7}},
        %Tile{score: 1, value: "O", position: %Position{row: 5, column: 7}},
        %Tile{score: 1, value: "O", position: %Position{row: 6, column: 7}},
        %Tile{score: 1, value: "B", position: %Position{row: 8, column: 7}},
        %Tile{score: 1, value: "A", position: %Position{row: 9, column: 7}},
        %Tile{score: 1, value: "R", position: %Position{row: 10, column: 7}}
      ]

      assert PlayIntegrityValidator.validate(existing_tiles, tiles) == {:ok, :vertical}
    end
  end
end
