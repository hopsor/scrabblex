defmodule Scrabblex.Games.PlayIntegrityValidator do
  @moduledoc """
  PlayIntegrityValidator module takes a Match and one of its Player and validates that the tiles provided for
  the next play meet the conditions.

  The validations performed here are only related to the positions occupied by the tiles. There will
  be a different module in charge of scanning the words composed by the tiles in play in a further step.
  """
  alias Scrabblex.Games.Tile
  alias Scrabblex.Games.Position

  def validate(_, []), do: {:error, :empty_play}

  def validate(played_tiles_matrix, playing_tiles) do
    with :ok <- valid_center?(played_tiles_matrix, playing_tiles),
         {:ok, alignment} <- check_alignment(playing_tiles),
         :ok <- valid_contiguity?(played_tiles_matrix, playing_tiles, alignment) do
      {:ok, alignment}
    end
  end

  defp valid_center?(played_tiles_matrix, tiles) when map_size(played_tiles_matrix) == 0 do
    if Enum.any?(tiles, &(&1.position.row == 7 && &1.position.column == 7)) do
      :ok
    else
      {:error, :center_not_found}
    end
  end

  defp valid_center?(_, _tiles), do: :ok

  defp valid_contiguity?(
         played_tiles_matrix,
         [%Tile{position: %Position{row: fixable_row, column: fixable_column}} | _] = tiles,
         alignment
       ) do
    moving_coord_sorted_indexes =
      tiles
      |> Enum.map(fn %Tile{position: %Position{row: row, column: column}} ->
        if alignment == :vertical, do: row, else: column
      end)
      |> Enum.sort_by(& &1, :asc)

    gaps = find_gaps(moving_coord_sorted_indexes)

    contiguity =
      case {gaps, played_tiles_matrix} do
        {[], played_tiles_matrix} when map_size(played_tiles_matrix) == 0 ->
          true

        {[], played_tiles_matrix} ->
          # Contiguity is confirmed by checking that at least one tile is adjacent with tiles from previous plays
          Enum.any?(tiles, fn %Tile{position: %Position{row: x, column: y}} ->
            [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
            |> Enum.any?(&Map.has_key?(played_tiles_matrix, &1))
          end)

        {gaps, played_tiles_matrix} ->
          # Contiguity is confirmed checking that ALL the gaps contain tiles from previous plays
          gaps
          |> Enum.map(fn gap_index ->
            if alignment == :vertical do
              {gap_index, fixable_column}
            else
              {fixable_row, gap_index}
            end
          end)
          |> Enum.all?(&Map.has_key?(played_tiles_matrix, &1))
      end

    if contiguity == true, do: :ok, else: {:error, :contiguity_error}
  end

  defp find_gaps(list) do
    range = Enum.min(list)..Enum.max(list) |> Enum.to_list()
    range -- list
  end

  defp check_alignment([_tile]), do: {:ok, :single}

  defp check_alignment([first_tile | rest]) do
    cond do
      Enum.all?(rest, &(&1.position.row == first_tile.position.row)) ->
        {:ok, :horizontal}

      Enum.all?(rest, &(&1.position.column == first_tile.position.column)) ->
        {:ok, :vertical}

      true ->
        {:error, :contiguity_error}
    end
  end
end
