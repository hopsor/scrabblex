defmodule ScrabblexWeb.PageControllerTest do
  use ScrabblexWeb.ConnCase

  import Scrabblex.AccountsFixtures

  test "GET / as logged user", %{conn: conn} do
    user = user_fixture()
    conn = conn |> log_in_user(user)
    conn = get(conn, ~p"/")

    assert redirected_to(conn) == ~p"/matches"
  end

  test "GET / as guest", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/users/log_in"
  end
end
