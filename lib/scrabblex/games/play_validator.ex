defmodule Scrabblex.Games.PlayValidator do
  alias Scrabblex.Games.{Match, Player}

  def validate(%Match{} = match, %Player{} = player) do
    with {:ok, played_tiles} <- get_played_tiles(player),
         :ok <- valid_center?(match, played_tiles),
         :ok <- valid_alignment?(played_tiles) do
      :ok
    end
  end

  defp get_played_tiles(%Player{hand: tiles}),
    do: {:ok, Enum.filter(tiles, &(!is_nil(&1.position)))}

  defp valid_center?(%Match{turn: 0}, tiles) do
    if Enum.any?(tiles, &(&1.position.row == 7 && &1.position.column == 7)) do
      :ok
    else
      {:error, :center_not_found}
    end
  end

  defp valid_center?(_, _), do: :ok

  defp valid_alignment?([first_tile | rest]) do
    if Enum.all?(rest, &(&1.position.row == first_tile.position.row)) or
         Enum.all?(rest, &(&1.position.column == first_tile.position.column)) do
      :ok
    else
      {:error, :tiles_not_aligned}
    end
  end
end
