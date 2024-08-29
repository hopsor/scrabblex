defmodule Scrabblex.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Scrabblex.Repo

  alias Scrabblex.Games.{BagBuilder, Match, Player, Tile}
  alias Scrabblex.Accounts.User

  @doc """
  Returns the list of matches scoped by user
  """
  def list_matches(%User{id: user_id}) do
    query = from m in Match, join: p in Player, on: m.id == p.match_id and p.user_id == ^user_id

    Repo.all(query)
    |> Repo.preload(players: [:user])
  end

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  def list_matches do
    Match
    |> Repo.all()
    |> Repo.preload(players: [:user])
  end

  @doc """
  Gets a single match.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_match!(id), do: Repo.get!(Match, id) |> Repo.preload(players: [:user])

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
      {:ok, match} -> {:ok, Repo.preload(match, players: [:user])}
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
    with {:ok, initial_bag} <- BagBuilder.build(match.dictionary),
         {:ok, hands, remaining_bag} <- BagBuilder.init_hands(initial_bag, match.players) do
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
        {:ok, match} -> {:ok, Repo.preload(match, players: :user)}
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

  def change_tile(%Tile{} = tile, attrs \\ %{}) do
    Tile.changeset(tile, attrs)
  end
end
