defmodule Scrabblex.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Scrabblex.Games` context.
  """

  alias Scrabblex.Repo
  alias Scrabblex.Games
  alias Scrabblex.Games.{Lexicon, Tile}

  @doc """
  Generate a match.
  """
  def match_fixture(attrs, :started) do
    match = match_fixture(attrs)
    {:ok, started_match} = Games.start_match(match)
    started_match
  end

  def match_fixture(attrs \\ %{}) do
    owner = Scrabblex.AccountsFixtures.user_fixture()

    {:ok, match} =
      %{
        lexicon_id: attrs[:lexicon_id] || lexicon_fixture() |> Map.get(:id),
        players: [%{user_id: owner.id, owner: true}]
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
    {:ok, lexicon} =
      %Lexicon{}
      |> Scrabblex.Games.Lexicon.changeset(
        Enum.into(attrs, %{name: "FISE-2", language: "es", flag: "🇪🇦"})
      )
      |> Repo.insert()

    lexicon
  end
end
