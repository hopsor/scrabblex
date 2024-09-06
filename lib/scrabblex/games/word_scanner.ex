defmodule Scrabblex.Games.WordScanner do
  @moduledoc """
  WordScanner takes a list of one or more new tiles and will scan the board trying to find the contiguous ones that were already on the board.

  The new words found as result of this scan will be returned.

  This module won't be responsible of verifying if the words are actually entries of the lexicon, that will be the job of a different module (TBD).
  """

  alias Scrabblex.Games.{BoardLayout, Maptrix, Tile}
  alias Scrabblex.Games.Word

  def scan(
        existing_tiles,
        new_tiles,
        :vertical
      ) do
    layout =
      BoardLayout.get()
      |> Maptrix.from_board_layout()

    [{first_tile_row, first_tile_column} | _] = Map.keys(new_tiles)

    vertical_word =
      find_word_vertically(
        first_tile_row,
        first_tile_column,
        new_tiles,
        layout,
        existing_tiles
      )

    horizontal_words =
      new_tiles
      |> Map.keys()
      |> Enum.map(fn {row, column} ->
        find_word_horizontally(row, column, new_tiles, layout, existing_tiles)
      end)

    {:ok, ([vertical_word] ++ horizontal_words) |> Enum.reject(&is_nil/1)}
  end

  def scan(
        existing_tiles,
        new_tiles,
        _alignment
      ) do
    layout =
      Scrabblex.Games.BoardLayout.get()
      |> Maptrix.from_board_layout()

    [{first_tile_row, first_tile_column} | _] = Map.keys(new_tiles)

    horizontal_word =
      find_word_horizontally(
        first_tile_row,
        first_tile_column,
        new_tiles,
        layout,
        existing_tiles
      )

    vertical_words =
      new_tiles
      |> Map.keys()
      |> Enum.map(fn {row, column} ->
        find_word_vertically(row, column, new_tiles, layout, existing_tiles)
      end)

    {:ok, ([horizontal_word] ++ vertical_words) |> Enum.reject(&is_nil/1)}
  end

  defp find_word_vertically(
         row,
         column,
         new_tiles,
         layout,
         existing_tiles
       ) do
    first_index =
      Enum.reduce_while(Enum.to_list(row..0), row, fn x, acc ->
        if Map.has_key?(new_tiles, {x, column}) or Map.has_key?(existing_tiles, {x, column}) do
          {:cont, x}
        else
          {:halt, acc}
        end
      end)

    last_index =
      Enum.reduce_while(Enum.to_list(row..14), row, fn x, acc ->
        if Map.has_key?(new_tiles, {x, column}) or Map.has_key?(existing_tiles, {x, column}) do
          {:cont, x}
        else
          {:halt, acc}
        end
      end)

    if first_index != last_index do
      {word_value, score, multipliers, positions} =
        first_index..last_index
        |> Enum.to_list()
        |> Enum.reduce({"", 0, [], []}, fn row_index,
                                           {acc_value, acc_score, acc_multipliers, acc_positions} ->
          existing_tile = Map.get(existing_tiles, {row_index, column})

          case existing_tile do
            %Tile{value: value, score: score, position: position} ->
              {acc_value <> value, acc_score + score, acc_multipliers,
               acc_positions ++ [position]}

            _ ->
              %Tile{value: value, score: score, position: position} =
                Map.get(new_tiles, {row_index, column})

              booster = Map.get(layout, {row_index, column})

              {acc_value <> value, acc_score + compute_score(score, booster),
               add_multiplier(acc_multipliers, booster), acc_positions ++ [position]}
          end
        end)

      %Word{
        value: word_value,
        score: Enum.reduce(multipliers, score, fn multiplier, acc -> acc * multiplier end),
        positions: positions
      }
    end
  end

  defp find_word_horizontally(
         row,
         column,
         new_tiles,
         layout,
         existing_tiles
       ) do
    first_index =
      Enum.reduce_while(Enum.to_list(column..0), column, fn y, acc ->
        if Map.has_key?(new_tiles, {row, y}) or Map.has_key?(existing_tiles, {row, y}) do
          {:cont, y}
        else
          {:halt, acc}
        end
      end)

    last_index =
      Enum.reduce_while(Enum.to_list(column..14), column, fn y, acc ->
        if Map.has_key?(new_tiles, {row, y}) or Map.has_key?(existing_tiles, {row, y}) do
          {:cont, y}
        else
          {:halt, acc}
        end
      end)

    if first_index != last_index do
      {word_value, score, multipliers, positions} =
        first_index..last_index
        |> Enum.to_list()
        |> Enum.reduce({"", 0, [], []}, fn column_index,
                                           {acc_value, acc_score, acc_multipliers, acc_positions} ->
          existing_tile = Map.get(existing_tiles, {row, column_index})

          case existing_tile do
            %Tile{value: value, score: score, position: position} ->
              {acc_value <> value, acc_score + score, acc_multipliers,
               acc_positions ++ [position]}

            _ ->
              %Tile{value: value, score: score, position: position} =
                Map.get(new_tiles, {row, column_index})

              booster = Map.get(layout, {row, column_index})

              {acc_value <> value, acc_score + compute_score(score, booster),
               add_multiplier(acc_multipliers, booster), acc_positions ++ [position]}
          end
        end)

      %Word{
        value: word_value,
        score: Enum.reduce(multipliers, score, fn multiplier, acc -> acc * multiplier end),
        positions: positions
      }
    end
  end

  defp compute_score(tile_score, "2L"), do: 2 * tile_score
  defp compute_score(tile_score, "3L"), do: 3 * tile_score
  defp compute_score(tile_score, _), do: tile_score

  defp add_multiplier(accumulator, "2W"), do: accumulator ++ [2]
  defp add_multiplier(accumulator, "3W"), do: accumulator ++ [3]

  defp add_multiplier(accumulator, _booster), do: accumulator
end
