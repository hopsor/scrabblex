defmodule Scrabblex.Games.BoardLayoutTest do
  use ExUnit.Case

  alias Scrabblex.Games.BoardLayout

  describe "get/0" do
    test "returns a list of 15*15 tuples with {x, y, slot_type}" do
      result = BoardLayout.get()

      assert length(result) == 15 * 15

      Enum.each(result, fn {x, y, value} ->
        assert x >= 0 && x < 15
        assert y >= 0 && y < 15
        assert value in ["3W", "2W", "3L", "2L", "X", nil]
      end)
    end
  end
end
