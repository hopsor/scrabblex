defmodule Scrabblex.Games.Bag do
  alias Scrabblex.Games.{BagDefinition, Tile}

  def new(lexicon) do
    bag =
      lexicon.bag_definitions
      |> Enum.flat_map(fn %BagDefinition{value: value, amount: amount, score: score} ->
        %{
          score: score,
          value: value,
          wildcard: value == "*"
        }
        |> List.duplicate(amount)
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

  When providing the option `strict: true`, if there weren't enough tiles to satisfy the demand then it'll
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
end
