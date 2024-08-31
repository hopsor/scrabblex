defmodule ScrabblexWeb.MatchLiveTest do
  use ScrabblexWeb.ConnCase

  import Phoenix.LiveViewTest
  import Scrabblex.{AccountsFixtures, GamesFixtures}

  alias Scrabblex.Games
  alias Scrabblex.Games.Match

  # TODO: Refactor
  defp create_match(_context) do
    match = match_fixture()
    %{match: match}
  end

  defp create_started_match(_context) do
    match = match_fixture(%{}, :started)
    %{match: match}
  end

  # More info here: https://hexdocs.pm/phoenix/Phoenix.Presence.html#module-testing-with-presence
  defp presence_callback(_) do
    on_exit(fn ->
      Process.sleep(100)

      for pid <- ScrabblexWeb.Presence.fetchers_pids() do
        ref = Process.monitor(pid)
        assert_receive {:DOWN, ^ref, _, _, _}, 1000
      end
    end)
  end

  describe "Index" do
    setup [:create_match, :presence_callback]

    test "lists all matches", %{conn: conn, match: _match} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      {:ok, _index_live, html} = live(conn, ~p"/matches")

      assert html =~ "Listing Matches"
    end

    test "saves new match", %{conn: conn, match: match} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      {:ok, index_live, _html} = live(conn, ~p"/matches")

      assert index_live |> element("a", "New Match") |> render_click() =~
               "New Match"

      assert_patch(index_live, ~p"/matches/new")

      assert {:ok, _view, html} =
               index_live
               |> form("#match-form", match: %{lexicon_id: match.lexicon_id})
               |> render_submit()
               |> follow_redirect(conn)

      assert html =~ "Match created successfully"
    end
  end

  describe "Show / Lobby" do
    setup [:create_match, :presence_callback]

    test "displays the lobby when match status is created", %{conn: conn, match: match} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      {:ok, _show_live, html} = live(conn, ~p"/matches/#{match}")

      assert html =~ "Lobby"
    end

    test "shows a join button when connected user isn't a player", %{conn: conn, match: match} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      {:ok, _show_live, html} = live(conn, ~p"/matches/#{match}")

      assert html =~ "Join"
    end

    test "shows a leave button when connected user is a player who isn't the owner", %{
      conn: conn,
      match: match
    } do
      user = user_fixture()
      _player = player_fixture(user_id: user.id, match_id: match.id)
      conn = log_in_user(conn, user)
      {:ok, _show_live, html} = live(conn, ~p"/matches/#{match}")

      assert html =~ "Leave"
    end

    test "won't show a join or leave button when connected user is the owner", %{
      conn: conn,
      match: match
    } do
      [owner_player] = match.players
      conn = log_in_user(conn, owner_player.user)
      {:ok, show_live, _html} = live(conn, ~p"/matches/#{match}")

      refute show_live |> element("#btn_join") |> has_element?()
      refute show_live |> element("#btn_leave") |> has_element?()
    end

    test "after someone connect I will see him online", %{conn: conn, match: match} do
      [owner_player] = match.players
      owner_conn = log_in_user(conn, owner_player.user)
      {:ok, show_live, _html} = live(owner_conn, ~p"/matches/#{match}")

      user = user_fixture()
      presence = %{id: user.id, user: user, metas: [%{phx_ref: "1234"}]}
      send(show_live.pid, {ScrabblexWeb.Presence, {:join, presence}})

      assert show_live |> element("#lobby_user_#{user.id} .online") |> has_element?()
    end

    test "after someone who isn't a player disconnects I won't see him at all", %{
      conn: conn,
      match: match
    } do
      [owner_player] = match.players
      owner_conn = log_in_user(conn, owner_player.user)
      {:ok, show_live, _html} = live(owner_conn, ~p"/matches/#{match}")

      user = user_fixture()
      presence = %{id: user.id, user: user, metas: []}
      send(show_live.pid, {ScrabblexWeb.Presence, {:leave, presence}})

      refute show_live |> element("#lobby_user_#{user.id}") |> has_element?()
    end

    test "after someone joins the match I will see it reflected in the lobby", %{
      conn: conn,
      match: match
    } do
      [owner_player] = match.players
      owner_conn = log_in_user(conn, owner_player.user)
      {:ok, show_live, _html} = live(owner_conn, ~p"/matches/#{match}")

      user = user_fixture()
      player = player_fixture(%{user_id: user.id, match_id: match.id})

      send(show_live.pid, %{event: "player_created", payload: player})

      assert show_live |> element("#lobby_user_#{user.id}") |> render() =~ "Joined"
    end

    test "after someone leaves the match I will see it reflected in the lobby", %{
      conn: conn,
      match: match
    } do
      [owner_player] = match.players
      owner_conn = log_in_user(conn, owner_player.user)
      user = user_fixture()
      player = player_fixture(%{user_id: user.id, match_id: match.id})

      {:ok, show_live, _html} = live(owner_conn, ~p"/matches/#{match}")

      Games.delete_player(player)
      send(show_live.pid, %{event: "player_deleted", payload: player})

      refute show_live |> element("#lobby_user_#{user.id}") |> has_element?()
    end

    test "after the match it's started players are shown the game board and the lobby is gone", %{
      conn: conn,
      match: match
    } do
      user = user_fixture()
      player = player_fixture(user_id: user.id, match_id: match.id)
      conn = log_in_user(conn, user)

      {:ok, show_live, _html} = live(conn, ~p"/matches/#{match}")
      updated_match = %Match{match | players: match.players ++ [player]}
      {:ok, started_match} = Games.start_match(updated_match)

      send(show_live.pid, %{event: "match_started", payload: started_match})

      rendered_view = render(show_live)

      assert rendered_view =~ "Game Board"
      refute rendered_view =~ "Lobby"
    end
  end

  describe "Show / Game Board" do
    setup [:create_started_match, :presence_callback]

    test "loading the component shows current score and my hand", %{
      conn: conn,
      match: %Match{players: [player1 | _] = players} = match
    } do
      conn = log_in_user(conn, player1.user)
      {:ok, show_live, html} = live(conn, ~p"/matches/#{match}")

      Enum.each(players, fn player ->
        assert html =~ "#{player.user.name}"
        assert html =~ "#{player.score}"
      end)

      element = element(show_live, "#hand")

      Enum.each(player1.hand, fn tile ->
        assert render(element) =~ tile.value
      end)
    end

    test "after player drops a tile in the board it triggers the update", %{
      conn: conn,
      match: %Match{players: [player1 | _]} = match
    } do
      [tile | _] = player1.hand
      conn = log_in_user(conn, player1.user)
      {:ok, show_live, _html} = live(conn, ~p"/matches/#{match}")

      show_live
      |> element("#game_board")
      |> render_hook("drop_tile", %{
        "id" => tile.id,
        "boardPosition" => %{
          "row" => 0,
          "column" => 0
        }
      })

      assert show_live
             |> element(
               ~s{#board_wrapper .slot[data-row="0"][data-column="0"] .tile[data-id="#{tile.id}"]}
             )
             |> has_element?()
    end

    test "after the player drops a tile in the hand it triggers the update", %{
      conn: conn,
      match: %Match{players: [player1 | _]} = match
    } do
      [tile | _] = player1.hand
      conn = log_in_user(conn, player1.user)
      {:ok, show_live, _html} = live(conn, ~p"/matches/#{match}")

      show_live
      |> element("#game_board")
      |> render_hook("drop_tile", %{
        "id" => tile.id,
        "handIndex" => 6
      })

      assert show_live
             |> element(~s{#hand .tile:last-child[data-id="#{tile.id}"]})
             |> has_element?()
    end

    test "after the player drops a tile anywhere with a stale session it reloads the page", %{
      conn: conn,
      match: %Match{players: [player | _]} = match
    } do
      [tile | _] = player.hand
      conn = log_in_user(conn, player.user)
      {:ok, show_live, _html} = live(conn, ~p"/matches/#{match}")

      # We simulate a hand update in a different session
      shuffled_hand = Enum.shuffle(player.hand)
      hand_changesets = Enum.map(shuffled_hand, &Games.change_tile/1)
      Games.update_player_hand(player, hand_changesets)

      assert {:error, {:live_redirect, _}} =
               show_live
               |> element("#game_board")
               |> render_hook("drop_tile", %{
                 "id" => tile.id,
                 "handIndex" => 6
               })
    end

    # TODO: Improve. The tiles in the hand are all already on the deck. Change the test so that before
    #       clicking the button some tiles are placed in the board.
    test "after the player clicks on the recover button all tiles on the board are brought back to the deck",
         %{conn: conn, match: %Match{players: [player | _]} = match} do
      conn = log_in_user(conn, player.user)
      {:ok, show_live, _html} = live(conn, ~p"/matches/#{match}")

      show_live
      |> element("#btn_recover")
      |> render_click()

      Enum.map(player.hand, fn tile ->
        assert show_live
               |> element(~s{#hand .tile[data-id="#{tile.id}"]})
               |> has_element?()
      end)
    end

    # TODO: Improve. Figure out a way to mock the inner `Enum.shuffle` of the event handler so that we
    #       can compare that the shuffling action is reflected in the rendered html
    test "after the player clicks on the shuffle button tiles on the deck are randomly rearranged",
         %{conn: conn, match: %Match{players: [player | _]} = match} do
      conn = log_in_user(conn, player.user)
      {:ok, show_live, _html} = live(conn, ~p"/matches/#{match}")

      show_live
      |> element("#btn_shuffle")
      |> render_click()

      Enum.map(player.hand, fn tile ->
        assert show_live
               |> element(~s{#hand .tile[data-id="#{tile.id}"]})
               |> has_element?()
      end)
    end

    test "when loading the board and it's my turn I see the submit button", %{
      conn: conn,
      match: %Match{players: [player | _]} = match
    } do
      conn = log_in_user(conn, player.user)
      {:ok, show_live, _html} = live(conn, ~p"/matches/#{match}")

      assert show_live |> element("#btn_submit_play") |> has_element?()
    end

    test "when loading the board and it isn't my turn I don't see the submit button", %{
      conn: conn,
      match: %Match{players: [_, player]} = match
    } do
      conn = log_in_user(conn, player.user)
      {:ok, show_live, _html} = live(conn, ~p"/matches/#{match}")

      refute show_live |> element("#btn_submit_play") |> has_element?()
    end
  end
end
