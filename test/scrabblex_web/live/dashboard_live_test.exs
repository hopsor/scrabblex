defmodule ScrabblexWeb.DashboardLiveTest do
  use ScrabblexWeb.ConnCase

  import Phoenix.LiveViewTest
  import Scrabblex.GamesFixtures

  alias Scrabblex.Games.Match

  test "lists all current_user matches", %{conn: conn} do
    match = match_fixture()
    owner = Match.owner(match)

    conn = log_in_user(conn, owner.user)
    {:ok, dashboard_live, html} = live(conn, ~p"/dashboard")

    assert html =~ owner.user.name
    assert html =~ "Match history"

    assert dashboard_live |> element("tbody#matches tr#matches-#{match.id}") |> has_element?()
  end
end
