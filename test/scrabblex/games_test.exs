defmodule Scrabblex.GamesTest do
  use Scrabblex.DataCase

  alias Scrabblex.Accounts.User
  alias Scrabblex.Games

  describe "lexicons" do
    alias Scrabblex.Games.{Lexicon}

    import Scrabblex.GamesFixtures

    test "list_lexicons/0 returns all lexicons" do
      lexicon = lexicon_fixture()
      assert Games.list_lexicons() == [lexicon]
    end

    test "list_lexicons/1 filters by enabled true/false" do
      lexicon = lexicon_fixture()
      _lexicon = lexicon_fixture(%{"enabled" => false})

      assert Games.list_lexicons(enabled: true) == [lexicon]
    end
  end

  describe "matches" do
    alias Scrabblex.Games.{Lexicon, Match, Play, Player, Tile}

    import Scrabblex.{AccountsFixtures, GamesFixtures}

    @invalid_attrs %{lexicon_id: nil}

    test "list_open_matches/1 returns given user private matches" do
      match1 = match_fixture(private: true)
      match1_id = match1.id
      _match2 = match_fixture(private: true, lexicon_id: match1.lexicon_id)

      owner_player = Match.owner(match1)
      assert [%Match{id: ^match1_id}] = Games.list_open_matches(owner_player.user)
    end

    test "list_open_matches/1 returns other users public matches" do
      match1 = match_fixture(private: false)
      match1_id = match1.id
      other_user = user_fixture()

      assert [%Match{id: ^match1_id}] = Games.list_open_matches(other_user)
    end

    test "list_open_matches/1 filters by lexicon_id" do
      match1 = match_fixture(private: true)
      match1_id = match1.id
      _match2 = match_fixture()

      owner_player = Match.owner(match1)

      assert [%Match{id: ^match1_id}] =
               Games.list_open_matches(owner_player.user, lexicon_id: match1.lexicon_id)
    end

    test "list_match_history/1 returns all matches for a given user" do
      match1 = match_fixture()
      match1_id = match1.id
      _match2 = match_fixture()

      owner_player = Match.owner(match1)

      assert [%Match{id: ^match1_id}] =
               Games.list_match_history(owner_player.user)
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Games.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      %User{id: owner_id} = user_fixture()
      %Lexicon{id: lexicon_id} = lexicon_fixture()
      valid_attrs = %{lexicon_id: lexicon_id, players: [%{user_id: owner_id, owner: true}]}

      assert {:ok, %Match{} = match} = Games.create_match(valid_attrs)
      assert match.lexicon_id == lexicon_id
      assert match.status == "created"
      assert match.turn == 0
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

    @tag skip: "Pending to implement"
    test "start_match/1 when the match hasn't enough players it returns {:error, :not_enough_players} error" do
    end

    test "exchange_tiles/3 when it isn't given player's turn returns {:error, :invalid_turn}" do
      match = match_fixture(%{}, :started)
      %Match{players: [_, player]} = match
      tiles = Enum.take(player.hand, 1)

      assert Games.exchange_tiles(match, player, tiles) == {:error, :invalid_turn}
    end

    test "exchange_tiles/3 when player provides more tiles than the bag has available then it returns {:error, :demand_exceeded}" do
      match = match_fixture(%{}, :started)
      %Match{players: [player, _]} = match
      tiles = Enum.take(player.hand, 1)

      match_with_empty_bag = %Match{match | bag: []}

      assert Games.exchange_tiles(match_with_empty_bag, player, tiles) ==
               {:error, :demand_exceeded}
    end

    test "exchange_tiles/3 when player provides no tiles it returns {:error, :empty_exchange}" do
      match = match_fixture(%{}, :started)
      %Match{players: [player | _]} = match

      assert Games.exchange_tiles(match, player, []) ==
               {:error, :empty_exchange}
    end

    test "exchange_tiles/3 with valid conditions replaces as many random tiles as the player provided" do
      match = match_fixture(%{}, :started)
      %Match{players: [player | _]} = match
      tiles = Enum.take(player.hand, 2)

      {:ok, %{match: %Match{bag: updated_bag}, player: updated_player}} =
        Games.exchange_tiles(match, player, tiles)

      bag_tile_ids = Enum.map(updated_bag, & &1.id)
      updated_player_tile_ids = Enum.map(updated_player.hand, & &1.id)

      assert Enum.all?(tiles, &(&1.id in bag_tile_ids))
      refute Enum.any?(tiles, &(&1.id in updated_player_tile_ids))
    end

    test "exchange_tiles/3 with valid conditions creates a exchange play" do
      match = match_fixture(%{}, :started)
      %Match{players: [player | _]} = match
      tiles = Enum.take(player.hand, 2)

      assert {:ok, %{play: %Play{type: "exchange"}}} =
               Games.exchange_tiles(match, player, tiles)
    end

    test "exchange_tiles/3 with valid conditions increments the turn" do
      match = match_fixture(%{}, :started)
      %Match{players: [player | _]} = match
      tiles = Enum.take(player.hand, 2)

      expected_turn = match.turn + 1

      assert {:ok, %{match: %Match{turn: ^expected_turn}}} =
               Games.exchange_tiles(match, player, tiles)
    end

    test "exchange_tiles/3 when a tile id is a wildcard exchanging it resets its value" do
      match = match_fixture(%{}, :started)
      %Match{players: [player, player2]} = match

      wildcard = %Tile{id: "tile-id", wildcard: true, value: "A", score: 0, position: nil}

      player_with_wildcard = %Player{
        player
        | hand: [wildcard]
      }

      {:ok, %{match: updated_match}} =
        Games.exchange_tiles(
          %Match{match | players: [player_with_wildcard, player2]},
          player_with_wildcard,
          [wildcard]
        )

      assert %Tile{value: ""} = Enum.find(updated_match.bag, &(&1.id == "tile-id"))
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

    test "update_player_hand/2 with valid data updates the player" do
      %Match{players: [player | _]} = match_fixture(%{}, :started)

      shuffled_hand = Enum.shuffle(player.hand)
      hand_changesets = Enum.map(shuffled_hand, &Games.change_tile/1)

      {:ok, updated_player} = Games.update_player_hand(player, hand_changesets)

      assert updated_player.hand == shuffled_hand
    end

    test "update_player_hand/2 based on stale data returns {:error, :stale_player}" do
      %Match{players: [player | _]} = match_fixture(%{}, :started)
      stale_player = %Player{player | lock_version: 0}
      shuffled_hand = Enum.shuffle(stale_player.hand)
      hand_changesets = shuffled_hand |> Enum.map(&Games.change_tile/1)

      assert Games.update_player_hand(stale_player, hand_changesets) == {:error, :stale_player}
    end

    @tag skip: "TODO: add after plays are already implemented"
    test "update_player_hand/2 when tiles are in already occupied positions returns {:error, :positions_already_filled}" do
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

    test "change_tile/1 returns a tile changeset" do
      tile = tile_fixture()
      assert %Ecto.Changeset{} = Games.change_tile(tile)
    end
  end

  describe "plays" do
    alias Scrabblex.Games.{Match, Tile, Play, Player, Position, Word}
    import Scrabblex.GamesFixtures

    setup :setup_valid_requirements

    test "create_play/2 with valid requirements returns the new play", %{
      match: match,
      player: player
    } do
      turn = match.turn

      assert {:ok,
              %{
                play: %Play{
                  score: 3,
                  turn: ^turn,
                  type: "play",
                  tiles: [
                    %{value: "F", score: 1, position: %Position{row: 7, column: 6}},
                    %{value: "O", score: 1, position: %Position{row: 7, column: 7}},
                    %{value: "O", score: 1, position: %Position{row: 7, column: 8}}
                  ],
                  words: [
                    %Word{
                      value: "FOO",
                      score: 3,
                      positions: [
                        %Position{row: 7, column: 6},
                        %Position{row: 7, column: 7},
                        %Position{row: 7, column: 8}
                      ]
                    }
                  ]
                }
              }} = Games.create_play(match, player)
    end

    test "create_play/2 with valid requirements updates the player score", %{
      match: match,
      player: player
    } do
      assert {:ok,
              %{
                player: %Player{score: 3}
              }} = Games.create_play(match, player)
    end

    test "create_play/2 with valid requirements replaces the tiles played in player's hand with new ones from the bag",
         %{
           match: match,
           player: player
         } do
      tile_ids_to_play =
        Enum.reject(player.hand, &is_nil(&1.position)) |> Enum.map(& &1.id)

      {:ok, %{player: updated_player, match: updated_match}} = Games.create_play(match, player)

      # Assert the player hand tiles doesn't contain anymore the played tiles
      assert Enum.all?(updated_player.hand, fn tile ->
               !Enum.member?(tile_ids_to_play, tile.id)
             end)

      # Assert the player hand is refilled
      assert length(updated_player.hand) == 7

      # Assert the match bag has gone down by as many tiles as the player dropped in the board
      assert length(updated_match.bag) == length(match.bag) - length(tile_ids_to_play)
    end

    test "create_play/2 with valid requirements while the bag is empty and the players hand gets empty changes the state of the match to finished",
         %{match: match, player: player} do
      empty_bag_match = %Match{match | bag: []}

      player_with_final_hand = %Player{
        player
        | hand: Enum.reject(player.hand, &is_nil(&1.position))
      }

      assert {:ok, %{match: %Match{status: "finished"}}} =
               Games.create_play(empty_bag_match, player_with_final_hand)
    end

    test "create_play/2 with non contiguous tiles returns {:error, :contiguity_error}" do
      match = %Match{plays: []}

      player = %Player{
        hand: [
          %Tile{
            value: "F",
            score: 1,
            wildcard: false,
            position: %Position{row: 7, column: 6}
          },
          %Tile{
            value: "O",
            score: 1,
            wildcard: false,
            position: %Position{row: 7, column: 7}
          },
          %Tile{
            value: "O",
            score: 1,
            wildcard: false,
            position: %Position{row: 7, column: 9}
          }
        ]
      }

      assert Games.create_play(match, player) == {:error, :contiguity_error}
    end

    test "create_play/2 with contiguous tiles but words not belonging to the lexicon returns {:error, :words_not_found, unmatched_entries} error" do
      match = %Match{plays: [], lexicon_id: 1}

      player = %Player{
        hand: [
          %Tile{
            value: "F",
            score: 1,
            wildcard: false,
            position: %Position{row: 7, column: 6}
          },
          %Tile{
            value: "O",
            score: 1,
            wildcard: false,
            position: %Position{row: 7, column: 7}
          },
          %Tile{
            value: "O",
            score: 1,
            wildcard: false,
            position: %Position{row: 7, column: 8}
          }
        ]
      }

      assert Games.create_play(match, player) == {:error, :words_not_found, ~w(FOO)}
    end

    test "skip_turn/2 with valid data returns the inserted play and the updated match", %{
      match: match,
      player: player
    } do
      expected_turn = match.turn + 1

      assert {:ok, %{play: %Play{type: "skip"}, match: %Match{turn: ^expected_turn}}} =
               Games.skip_turn(match, player)
    end

    def setup_valid_requirements(_ctx) do
      match = match_fixture(%{}, :started)
      %Match{players: [player1, _], lexicon_id: lexicon_id} = match
      lexicon_entry_fixture(%{name: "FOO", lexicon_id: lexicon_id})

      {:ok, player} =
        Games.update_player_hand(player1, [
          Games.change_tile(%Tile{}, %{
            value: "F",
            score: 1,
            wildcard: false,
            position: %{row: 7, column: 6}
          }),
          Games.change_tile(%Tile{}, %{
            value: "O",
            score: 1,
            wildcard: false,
            position: %{row: 7, column: 7}
          }),
          Games.change_tile(%Tile{}, %{
            value: "O",
            score: 1,
            wildcard: false,
            position: %{row: 7, column: 8}
          }),
          Games.change_tile(%Tile{}, %{value: "B", score: 1, wildcard: false}),
          Games.change_tile(%Tile{}, %{value: "A", score: 1, wildcard: false}),
          Games.change_tile(%Tile{}, %{value: "R", score: 1, wildcard: false}),
          Games.change_tile(%Tile{}, %{value: "Z", score: 1, wildcard: false})
        ])

      {:ok, %{match: match, player: player}}
    end
  end
end
