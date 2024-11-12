defmodule ScrabblexWeb.UserProfileLiveTest do
  use ScrabblexWeb.ConnCase

  import Phoenix.LiveViewTest
  import Scrabblex.{AccountsFixtures, GamesFixtures}

  alias Scrabblex.Games.{Match, Player}

  test "lists all current_user matches", %{conn: conn} do
    user = user_fixture()
    match = match_fixture()
    %Player{user: profile_user} = Match.owner(match)

    conn = log_in_user(conn, user)
    {:ok, profile_live, html} = live(conn, ~p"/u/#{profile_user.name}")

    assert html =~ profile_user.name
    assert html =~ "Match history"

    assert profile_live |> element("tbody#matches tr#matches-#{match.id}") |> has_element?()
  end
end
