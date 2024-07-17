defmodule ScrabblexWeb.MatchLiveTest do
  alias Scrabblex.AccountsFixtures
  use ScrabblexWeb.ConnCase

  import Phoenix.LiveViewTest
  import Scrabblex.GamesFixtures

  @create_attrs %{dictionary: "fise"}

  defp create_match(_) do
    match = match_fixture()
    %{match: match}
  end

  describe "Index" do
    setup [:create_match]

    test "lists all matches", %{conn: conn, match: match} do
      user = AccountsFixtures.user_fixture()
      conn = log_in_user(conn, user)
      {:ok, _index_live, html} = live(conn, ~p"/matches")

      assert html =~ "Listing Matches"
      assert html =~ match.dictionary
    end

    test "saves new match", %{conn: conn} do
      user = AccountsFixtures.user_fixture()
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
      assert html =~ "fise"
    end
  end

  describe "Show" do
    setup [:create_match]

    test "displays match", %{conn: conn, match: match} do
      user = AccountsFixtures.user_fixture()
      conn = log_in_user(conn, user)
      {:ok, _show_live, html} = live(conn, ~p"/matches/#{match}")

      assert html =~ "Show Match"
      assert html =~ match.dictionary
    end
  end
end
