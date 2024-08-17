defmodule ScrabblexWeb.LobbyStateTest do
  use ExUnit.Case, async: true

  alias ScrabblexWeb.MatchLive.LobbyState
  alias ScrabblexWeb.MatchLive.LobbyState.Item
  alias Scrabblex.Accounts.User
  alias Scrabblex.Games.Player

  describe "compute/2" do
    test "when a user is connected but didn't join returns it in the list with proper flags" do
      players = []

      presences = %{
        1 => %{
          id: 1,
          user: %User{id: 1},
          metas: [%{phx_ref: "123abc"}]
        }
      }

      assert [%Item{online: true, joined: false}] = LobbyState.compute(players, presences)
    end

    test "when a user isn't connected but joined returns it in the list with proper flags" do
      players = [%Player{user_id: 1, match_id: 2}]

      presences = %{}

      assert [%Item{online: false, joined: true}] = LobbyState.compute(players, presences)
    end

    test "when a user connected and joined returns it in the list with proper flags" do
      players = [%Player{user_id: 1, match_id: 2}]

      presences = %{
        1 => %{
          id: 1,
          user: %User{id: 1},
          metas: [%{phx_ref: "123abc"}]
        }
      }

      assert [%Item{online: true, joined: true}] = LobbyState.compute(players, presences)
    end
  end
end
