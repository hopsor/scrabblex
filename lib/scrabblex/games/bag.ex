defmodule Scrabblex.Games.Bag do
  alias Scrabblex.Games.Tile

  def new(lexicon_name) do
    bag =
      lexicon_name
      |> distribution()
      |> Enum.flat_map(fn {letter, %{available: available, score: score}} ->
        %{
          score: score,
          value: letter,
          wildcard: letter == "*"
        }
        |> List.duplicate(available)
      end)
      |> Enum.shuffle()

    {:ok, bag}
  end

  def init_hands(initial_bag, players) do
    players_count = Enum.count(players)

    {all_players_hands, remaining_bag} = Enum.split(initial_bag, players_count * 7)

    initial_hands = Enum.chunk_every(all_players_hands, 7)

    {:ok, initial_hands, remaining_bag}
  end

  @doc """
  Given a bag (list of `%Tile{}`) and a demand (Integer) it substracts as many tiles as demanded from the bag.

  The return tuple expected is below:

  {:ok, demanded_tiles, remainder}

  In case there aren't enough tiles in the bag to satisfy the demand it will return as many as possible emptying the bag.

  In case of providing the option `strict: false` if there weren't enough tiles to satisfy the demand it'll
  return {:error, :demand_exceeded}
  """
  @draw_tiles_defaults %{strict: false}
  def draw_tiles(bag, demand, opts \\ []) do
    %{strict: strict} = Enum.into(opts, @draw_tiles_defaults)

    cond do
      strict && demand > length(bag) ->
        {:error, :demand_exceeded}

      true ->
        draw_tiles!(bag, demand)
    end
  end

  defp draw_tiles!([], _), do: {:ok, [], []}

  defp draw_tiles!(bag, demand) do
    {tiles_drawn, bag_remainder} =
      bag
      |> Enum.shuffle()
      |> Enum.split(demand)

    {:ok, tiles_drawn, bag_remainder}
  end

  def reinstate_tiles(bag, tiles) do
    {:ok,
     bag ++
       Enum.map(tiles, fn tile ->
         if tile.wildcard do
           %Tile{tile | value: "", position: nil}
         else
           %Tile{tile | position: nil}
         end
       end)}
  end

  def distribution("FISE-2") do
    %{
      "A" => %{score: 1, available: 12},
      "E" => %{score: 1, available: 12},
      "I" => %{score: 1, available: 6},
      "L" => %{score: 1, available: 4},
      "N" => %{score: 1, available: 5},
      "O" => %{score: 1, available: 9},
      "R" => %{score: 1, available: 5},
      "S" => %{score: 1, available: 6},
      "T" => %{score: 1, available: 4},
      "U" => %{score: 1, available: 5},
      "D" => %{score: 2, available: 5},
      "G" => %{score: 2, available: 2},
      "B" => %{score: 3, available: 2},
      "C" => %{score: 3, available: 4},
      "M" => %{score: 3, available: 2},
      "P" => %{score: 3, available: 2},
      "F" => %{score: 4, available: 1},
      "H" => %{score: 4, available: 2},
      "V" => %{score: 4, available: 1},
      "Y" => %{score: 4, available: 1},
      "CH" => %{score: 5, available: 1},
      "Q" => %{score: 5, available: 1},
      "J" => %{score: 8, available: 1},
      "LL" => %{score: 8, available: 1},
      "Ñ" => %{score: 8, available: 1},
      "RR" => %{score: 8, available: 1},
      "X" => %{score: 8, available: 1},
      "Z" => %{score: 10, available: 1},
      "*" => %{score: 0, available: 2}
    }
  end
end
