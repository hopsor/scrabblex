defmodule Scrabblex.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Scrabblex.Games` context.
  """

  @doc """
  Generate a match.
  """
  def match_fixture(attrs \\ %{}) do
    owner = Scrabblex.AccountsFixtures.user_fixture()

    {:ok, match} =
      attrs
      |> Enum.into(%{
        dictionary: "fise2",
        players: [%{user_id: owner.id, owner: true}]
      })
      |> Scrabblex.Games.create_match()

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
end
