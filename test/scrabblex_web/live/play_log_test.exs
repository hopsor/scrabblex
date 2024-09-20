defmodule ScrabblexWeb.PlayLogTest do
  use ExUnit.Case

  import Phoenix.LiveViewTest

  alias ScrabblexWeb.MatchLive.PlayLog
  alias Scrabblex.Accounts.User
  alias Scrabblex.Games.{Play, Player, Word}

  describe "play/1" do
    test "renders the player name, score and words composed" do
      play = %Play{
        score: 10,
        player: %Player{
          user: %User{name: "John"}
        },
        words: [%Word{value: "FOO"}]
      }

      assert render_component(&PlayLog.play/1, play: play) ==
               "<div class=\"play\">\n  <strong>John</strong>\n  earned <strong>10 points</strong>\n  by composing words:<br>FOO\n</div>"
    end
  end

  describe "skip/1" do
    test "renders the player name" do
      play = %Play{
        player: %Player{
          user: %User{name: "John"}
        }
      }

      assert render_component(&PlayLog.skip/1, play: play) ==
               "<div class=\"skip\"><strong>John</strong> skipped turn</div>"
    end
  end

  describe "exchange/1" do
    test "renders the player name" do
      play = %Play{
        player: %Player{
          user: %User{name: "John"}
        }
      }

      assert render_component(&PlayLog.exchange/1, play: play) ==
               "<div class=\"exchange\"><strong>John</strong> exchanged tiles</div>"
    end
  end
end
