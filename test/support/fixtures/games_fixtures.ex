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
        dictionary: "fise",
        players: [%{user_id: owner.id, owner: true}]
      })
      |> Scrabblex.Games.create_match()

    match
  end

  @doc """
  Generate a player.
  """
  def player_fixture(attrs \\ %{}) do
    user = Scrabblex.AccountsFixtures.user_fixture()

    {:ok, player} =
      attrs
      |> Enum.into(%{
        owner: true,
        user_id: user.id
      })
      |> Scrabblex.Games.create_player()

    player
  end
end
