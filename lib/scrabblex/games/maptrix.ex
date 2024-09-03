defmodule Scrabblex.Games.Maptrix do
  @moduledoc """
  This module is specially helpful in order to work with PlayIntegrityValidator and WordScanner.

  In essence it takes different structures containing tiles or other things like the layout and returns a map.

  The map keys are the coordinates {row, column} of each element we are interested in.
  """
  alias Scrabblex.Games.{Match, Player, Play}

  @doc """

  """
  def from_match(%Match{plays: plays}) do
    plays
    |> Enum.filter(&(&1.type == "play"))
    |> Enum.flat_map(fn %Play{tiles: tiles} ->
      Enum.map(tiles, fn tile ->
        {{tile.position.row, tile.position.column}, tile}
      end)
    end)
    |> Enum.into(%{})
  end

  @doc """

  """
  def from_player(%Player{} = player) do
    player
    |> Player.playing_tiles()
    |> Enum.reduce(%{}, fn tile, acc ->
      Map.put(acc, {tile.position.row, tile.position.column}, tile)
    end)
  end

  def from_board_layout(board_layout) do
    board_layout
    |> Enum.reject(fn {_, _, value} ->
      is_nil(value) || value == "X"
    end)
    |> Enum.reduce(%{}, fn {x, y, value}, acc ->
      Map.put(acc, {x, y}, value)
    end)
  end
end
