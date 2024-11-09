defmodule Scrabblex.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Scrabblex.Games` context.
  """

  alias Scrabblex.Repo
  alias Scrabblex.Games
  alias Scrabblex.Games.{BagDefinition, Match, Lexicon, LexiconEntry, Play, Tile}

  @doc """
  Generate a match.
  """
  def match_fixture(attrs, :started) do
    match = match_fixture(attrs)
    new_player = player_fixture(%{match_id: match.id})

    {:ok, started_match} =
      Games.start_match(%Match{match | players: match.players ++ [new_player]})

    started_match
  end

  def match_fixture(attrs \\ %{}) do
    owner = Scrabblex.AccountsFixtures.user_fixture()

    {:ok, match} =
      %{
        lexicon_id: attrs[:lexicon_id] || lexicon_fixture() |> Map.get(:id),
        players: [%{user_id: owner.id, owner: true}],
        private: attrs[:private] || false
      }
      |> Games.create_match()

    match
  end

  @doc """
  Generate a player.
  """
  def player_fixture(attrs \\ %{}) do
    {:ok, player} =
      %{
        owner: false,
        user_id: attrs[:user_id] || Scrabblex.AccountsFixtures.user_fixture() |> Map.get(:id),
        match_id: attrs[:match_id] || match_fixture() |> Map.get(:id)
      }
      |> Scrabblex.Games.create_player()

    player
  end

  @doc """
  Generate a play.
  """
  def play_fixture(attrs \\ %{}) do
    {:ok, play} =
      Repo.insert(%Play{
        score: attrs[:score] || 10,
        turn: attrs[:turn] || 0,
        type: attrs[:type] || "play",
        player_id: attrs[:player_id],
        match_id: attrs[:match_id],
        tiles: attrs[:tiles] || [],
        words: attrs[:words] || []
      })

    play
  end

  @doc """
  Generate a tile.
  """
  def tile_fixture(attrs \\ %{}) do
    %Tile{
      score: attrs[:score] || 1,
      value: attrs[:value] || "A",
      wildcard: attrs[:wildcard] || false,
      position: attrs[:position] || nil
    }
  end

  @doc """
  Generate a lexicon
  """
  def lexicon_fixture(attrs \\ %{}) do
    defaults = %{
      "name" => "FISE-2",
      "language" => "es",
      "flag" => "🇪🇦",
      "enabled" => true,
      "bag_definitions" =>
        Enum.map(bag_definitions_attrs(), &BagDefinition.changeset(%BagDefinition{}, &1))
    }

    {:ok, lexicon} =
      %Lexicon{}
      |> Scrabblex.Games.Lexicon.changeset(Enum.into(attrs, defaults))
      |> Repo.insert()

    lexicon
  end

  def lexicon_entry_fixture(attrs \\ %{}) do
    {:ok, lexicon_entry} =
      %LexiconEntry{} |> LexiconEntry.changeset(Enum.into(attrs, %{})) |> Repo.insert()

    lexicon_entry
  end

  def bag_definitions_attrs() do
    ?A..?Z
    |> Enum.map(&%{"value" => <<&1>>, "score" => 1, "amount" => 4})
  end
end
