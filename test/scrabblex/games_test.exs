defmodule Scrabblex.GamesTest do
  use Scrabblex.DataCase

  alias Scrabblex.Accounts.User
  alias Scrabblex.Games

  describe "matches" do
    alias Scrabblex.Games.{Match, Player}

    import Scrabblex.{AccountsFixtures, GamesFixtures}

    @invalid_attrs %{dictionary: nil}

    test "list_matches/1 returns all matches scoped by user" do
      match1 = match_fixture()
      _match2 = match_fixture()

      owner_player = Match.owner(match1)
      assert Games.list_matches(owner_player.user) == [match1]
    end

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
      valid_attrs = %{dictionary: "fise2", players: [%{user_id: owner_id, owner: true}]}

      assert {:ok, %Match{} = match} = Games.create_match(valid_attrs)
      assert match.dictionary == "fise2"
      assert match.status == "created"
      assert [%Player{user_id: ^owner_id}] = match.players
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_match(@invalid_attrs)
    end

    test "start_match/1 when the match status is different of `created` returns :match_already_started error" do
      match = match_fixture()
      started_match = %Match{match | status: "started"}

      assert {:error, :match_already_started} == Games.start_match(started_match)
    end

    test "start_match/1 when the match is valid it changes the status to `started`" do
      match = match_fixture()
      player_fixture(match_id: match.id)

      assert {:ok, %Match{status: "started"}} = Games.start_match(match)
    end

    test "start_match/1 when the match is valid it hands out 7 random tiles to every player" do
      match = match_fixture()
      player_fixture(match_id: match.id)
      {:ok, %Match{players: players}} = Games.start_match(match)

      Enum.each(players, fn player ->
        assert length(player.hand) == 7
      end)
    end

    test "start_match/1 when the match is valid it fills the bag with tiles" do
      match = match_fixture()
      player_fixture(match_id: match.id)
      {:ok, started_match} = Games.start_match(match)

      assert length(started_match.bag) > 0
    end
  end

  describe "players" do
    alias Scrabblex.Games.{Match, Player}

    import Scrabblex.{AccountsFixtures, GamesFixtures}

    @invalid_attrs %{owner: nil}

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Games.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      %User{id: user_id} = user_fixture()
      %Match{id: match_id} = match_fixture()

      valid_attrs = %{match_id: match_id, user_id: user_id, owner: false}

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
