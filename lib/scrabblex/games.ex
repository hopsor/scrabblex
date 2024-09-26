defmodule Scrabblex.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Scrabblex.Repo

  alias Scrabblex.Games.{
    Bag,
    Lexicon,
    LexiconResolver,
    Match,
    Maptrix,
    Play,
    Player,
    PlayIntegrityValidator,
    Tile,
    Word,
    WordScanner
  }

  alias Scrabblex.Accounts.User

  @doc """
  Returns the list of matches scoped by user
  """
  def list_matches(%User{id: user_id}) do
    query = from m in Match, join: p in Player, on: m.id == p.match_id and p.user_id == ^user_id

    Repo.all(query)
    |> Repo.preload([:lexicon, players: [:user]])
  end

  def get_match!(friendly_id) when is_binary(friendly_id) do
    Match
    |> Repo.get_by!(friendly_id: friendly_id)
    |> Repo.preload([:lexicon, players: [:user], plays: [player: :user]])
  end

  @doc """
  Gets a single match by its id.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_match!(id) do
    Match
    |> Repo.get!(id)
    |> Repo.preload([:lexicon, players: [:user], plays: [player: :user]])
  end

  @doc """
  Creates a match.

  ## Examples

      iex> create_match(%{field: value})
      {:ok, %Match{}}

      iex> create_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_match(attrs \\ %{}) do
    result =
      %Match{}
      |> Match.create_changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, match} -> {:ok, Repo.preload(match, [:plays, :lexicon, players: [:user]])}
      error -> error
    end
  end

  @doc """
  Updates a match.

  ## Examples

      iex> update_match(match, %{field: new_value})
      {:ok, %Match{}}

      iex> update_match(match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match.

  ## Examples

      iex> delete_match(match)
      {:ok, %Match{}}

      iex> delete_match(match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  @doc """
  Starts a match.

  Changes it's status to started, builds a bag and hands out 7 tiles to each player

  ## Examples

      iex> start_match(match)
      {:ok, %Match{}}
  """
  def start_match(%Match{status: "created"} = match) do
    with {:ok, initial_bag} <- Bag.new(match.lexicon.name),
         {:ok, hands, remaining_bag} <- Bag.init_hands(initial_bag, match.players) do
      players_changeset =
        hands
        |> Enum.with_index()
        |> Enum.map(fn {hand, index} ->
          player = Enum.at(match.players, index)
          Player.start_changeset(player, %{hand: hand})
        end)

      changeset =
        Match.start_changeset(match, %{
          bag: remaining_bag,
          players: players_changeset
        })

      changeset
      |> Repo.update()
      |> case do
        {:ok, match} -> {:ok, Repo.preload(match, [:plays, :lexicon, players: [:user]])}
        error -> error
      end
    end
  end

  def start_match(%Match{status: _}), do: {:error, :match_already_started}

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match changes.

  ## Examples

      iex> change_match(match)
      %Ecto.Changeset{data: %Match{}}

  """
  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end

  alias Scrabblex.Games.Player

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id) |> Repo.preload(:user)

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, player} -> {:ok, Repo.preload(player, :user)}
      error -> error
    end
  end

  @doc """
  Updates a player's hand.

  ## Examples

      iex> update_player_hand(player, hand_changesets)
      {:ok, %Player{}}

      iex> update_player_hand(player, hand_changesets)
      {:error, %Ecto.Changeset{}}

  """
  def update_player_hand(%Player{} = player, hand) do
    player
    |> Player.hand_changeset(hand)
    |> Repo.update()
    |> case do
      {:ok, updated_player} -> {:ok, Repo.preload(updated_player, :user)}
      error -> error
    end
  rescue
    Ecto.StaleEntryError -> {:error, :stale_player}
  end

  @doc """
  Deletes a player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{data: %Player{}}

  """
  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tile changes.

  ## Examples

      iex> change_tile(tile)
      %Ecto.Changeset{data: %Tile{}}

  """
  def change_tile(%Tile{} = tile, attrs \\ %{}) do
    Tile.changeset(tile, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking word changes.

  ## Examples

      iex> change_word(word)
      %Ecto.Changeset{data: %Word{}}

  """
  def change_word(%Word{} = word, attrs \\ %{}) do
    Word.changeset(word, attrs)
  end

  @doc """
  Returns the list of lexicons.

  ## Examples

      iex> list_lexicons()
      [%Lexicon{}, ...]

  """
  def list_lexicons() do
    Lexicon
    |> Repo.all()
  end

  @doc """
  Creates a play based on a match and a given player

  A successful create_play call will:

  - Create a new play
  - Update match increasing the turn and updating the bag removing drawn tiles
    and setting the status to finished if conditions apply
  - Update player removing the play tiles, adding the new ones drawn from the bag
    and also adding the play points to his score
  """
  def create_play(%Match{} = match, %Player{} = player) do
    played_tiles_matrix = Maptrix.from_match(match)
    new_tiles_matrix = Maptrix.from_player(player)
    new_tiles = Player.playing_tiles(player)

    with {:ok, alignment} <- PlayIntegrityValidator.validate(played_tiles_matrix, new_tiles),
         {:ok, words} <- WordScanner.scan(played_tiles_matrix, new_tiles_matrix, alignment),
         :ok <- LexiconResolver.resolve(match, Enum.map(words, & &1.value)),
         {:ok, tiles_drawn, bag_remainder} <- Bag.draw_tiles(match.bag, Enum.count(new_tiles)) do
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :play,
        Play.changeset(%Play{}, %{
          tiles: Enum.map(new_tiles, &change_tile/1),
          words: Enum.map(words, &change_word/1),
          turn: match.turn,
          type: "play",
          match_id: match.id,
          player_id: player.id
        })
      )
      |> Ecto.Multi.update(:match, fn _ ->
        unplayed_tiles_count =
          player.hand
          |> Enum.filter(&is_nil(&1.position))
          |> Enum.count()

        match_changes = %{
          bag: Enum.map(bag_remainder, &change_tile/1)
        }

        case Enum.count(tiles_drawn) + unplayed_tiles_count do
          0 ->
            Match.play_changeset(match, Map.put(match_changes, :status, "finished"))

          _ ->
            Match.play_changeset(match, match_changes)
        end
      end)
      |> Ecto.Multi.update(:player, fn %{play: %Play{score: play_score}} ->
        updated_hand =
          player.hand
          |> Enum.filter(&is_nil(&1.position))
          |> Enum.concat(tiles_drawn)

        Player.turn_changeset(player, %{
          score: player.score + play_score,
          hand: Enum.map(updated_hand, &change_tile/1)
        })
      end)
      |> Repo.transaction()
    end
  end

  def skip_turn(%Match{turn: turn} = match, %Player{} = player) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :play,
      Play.changeset(%Play{}, %{
        turn: turn,
        player_id: player.id,
        match_id: match.id,
        type: "skip"
      })
    )
    |> Ecto.Multi.update(:match, Match.skip_turn_changeset(match))
    |> Repo.transaction()
  end

  def exchange_tiles(_, _, []), do: {:error, :empty_exchange}

  def exchange_tiles(%Match{turn: turn} = match, %Player{} = player, selected_tiles) do
    with :ok <- is_valid_turn?(match, player),
         {:ok, tiles_drawn, remainder} <-
           Bag.draw_tiles(match.bag, length(selected_tiles), strict: true),
         {:ok, updated_bag} <- Bag.reinstate_tiles(remainder, selected_tiles) do
      updated_bag_changesets = Enum.map(updated_bag, &change_tile/1)
      hand_changesets = Enum.map((player.hand -- selected_tiles) ++ tiles_drawn, &change_tile/1)

      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :play,
        Play.changeset(%Play{}, %{
          turn: turn,
          player_id: player.id,
          match_id: match.id,
          type: "exchange"
        })
      )
      |> Ecto.Multi.update(:player, Player.exchange_changeset(player, %{hand: hand_changesets}))
      |> Ecto.Multi.update(
        :match,
        Match.exchange_tiles_changeset(match, %{bag: updated_bag_changesets})
      )
      |> Repo.transaction()
    end
  end

  defp is_valid_turn?(%Match{turn: turn, players: players}, %Player{} = player) do
    index = Enum.find_index(players, &(&1 == player))
    if rem(turn, length(players)) == index, do: :ok, else: {:error, :invalid_turn}
  end
end
