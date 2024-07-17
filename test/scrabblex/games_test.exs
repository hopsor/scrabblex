defmodule Scrabblex.GamesTest do
  use Scrabblex.DataCase

  alias Scrabblex.Accounts.User
  alias Scrabblex.Games
  alias Scrabblex.Games.Player

  describe "matches" do
    alias Scrabblex.Games.Match

    import Scrabblex.{AccountsFixtures, GamesFixtures}

    @invalid_attrs %{dictionary: nil}

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert Games.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Games.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      %User{id: owner_id} = user_fixture()
      valid_attrs = %{dictionary: "fise", players: [%{user_id: owner_id, owner: true}]}

      assert {:ok, %Match{} = match} = Games.create_match(valid_attrs)
      assert match.dictionary == "fise"
      assert match.status == "created"
      assert [%Player{user_id: ^owner_id}] = match.players
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_match(@invalid_attrs)
    end
  end

  describe "players" do
    alias Scrabblex.Games.Player

    import Scrabblex.{AccountsFixtures, GamesFixtures}

    @invalid_attrs %{owner: nil}

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Games.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Games.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      %User{id: user_id} = user_fixture()

      valid_attrs = %{user_id: user_id, owner: false}

      assert {:ok, %Player{} = player} = Games.create_player(valid_attrs)
      assert player.user_id == user_id
      assert player.owner == false
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      update_attrs = %{owner: false}

      assert {:ok, %Player{} = player} = Games.update_player(player, update_attrs)
      assert player.owner == false
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_player(player, @invalid_attrs)
      assert player == Games.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Games.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Games.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Games.change_player(player)
    end
  end
end
