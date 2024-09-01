defmodule Scrabblex.Games.PlayValidator do
  @moduledoc """
  PlayValidator module takes a Match and one of its Player and validates that the tiles provided for
  the next play meet the conditions.

  The validations performed here are only related to the positions occupied by the tiles. There will
  be a different module in charge of scanning the words composed by the tiles in play in a further step.
  """
  alias Scrabblex.Games.{Match, Play, Player, Tile}
  alias Scrabblex.Games.Tile.Position

  def validate(%Match{} = match, %Player{} = player) do
    with {:ok, playing_tiles} <- get_playing_tiles(player),
         {:ok, maptrix} <- build_maptrix(match),
         :ok <- valid_center?(maptrix, playing_tiles),
         {:ok, alignment} <- check_alignment(playing_tiles),
         :ok <- valid_contiguity?(maptrix, playing_tiles, alignment) do
      :ok
    end
  end

  defp get_playing_tiles(%Player{hand: tiles}) do
    case Enum.filter(tiles, &(!is_nil(&1.position))) do
      [] -> {:error, :empty_play}
      playing_tiles -> {:ok, playing_tiles}
    end
  end

  defp valid_center?(maptrix, tiles) when map_size(maptrix) == 0 do
    if Enum.any?(tiles, &(&1.position.row == 7 && &1.position.column == 7)) do
      :ok
    else
      {:error, :center_not_found}
    end
  end

  defp valid_center?(_, _tiles), do: :ok

  defp valid_contiguity?(
         maptrix,
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
      case {gaps, maptrix} do
        {[], maptrix} when map_size(maptrix) == 0 ->
          true

        {[], maptrix} ->
          # Contiguity is confirmed by checking that at least one tile is adjacent with tiles from previous plays
          Enum.any?(tiles, fn %Tile{position: %Position{row: x, column: y}} ->
            [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
            |> Enum.any?(&Map.has_key?(maptrix, &1))
          end)

        {gaps, maptrix} ->
          # Contiguity is confirmed checking that ALL the gaps contain tiles from previous plays
          gaps
          |> Enum.map(fn gap_index ->
            if alignment == :vertical do
              {gap_index, fixable_column}
            else
              {fixable_row, gap_index}
            end
          end)
          |> Enum.all?(&Map.has_key?(maptrix, &1))
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

  defp build_maptrix(%Match{plays: plays}) do
    maptrix =
      plays
      |> Enum.filter(&(&1.type == "play"))
      |> Enum.flat_map(fn %Play{tiles: tiles} ->
        Enum.map(tiles, fn tile ->
          {{tile.position.row, tile.position.column}, tile}
        end)
      end)
      |> Enum.into(%{})

    {:ok, maptrix}
  end
end
