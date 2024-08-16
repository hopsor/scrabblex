defmodule ScrabblexWeb.MatchLiveTest do
  use ScrabblexWeb.ConnCase

  import Phoenix.LiveViewTest
  import Scrabblex.{AccountsFixtures, GamesFixtures}

  alias Scrabblex.Games

  @create_attrs %{dictionary: "fise"}

  defp create_match(_) do
    match = match_fixture()
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

    test "saves new match", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      {:ok, index_live, _html} = live(conn, ~p"/matches")

      assert index_live |> element("a", "New Match") |> render_click() =~
               "New Match"

      assert_patch(index_live, ~p"/matches/new")

      assert {:ok, _view, html} =
               index_live
               |> form("#match-form", match: @create_attrs)
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
  end
end
