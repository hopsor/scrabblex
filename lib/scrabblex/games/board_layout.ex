defmodule Scrabblex.Games.BoardLayout do
  @content [
    ["3W", nil, nil, "2L", nil, nil, nil, "3W", nil, nil, nil, "2L", nil, nil, "3W"],
    [nil, "2W", nil, nil, nil, "3L", nil, nil, nil, "3L", nil, nil, nil, "2W", nil],
    [nil, nil, "2W", nil, nil, nil, "2L", nil, "2L", nil, nil, nil, "2W", nil, nil],
    ["2L", nil, nil, "2W", nil, nil, nil, "2L", nil, nil, nil, "2W", nil, nil, "2L"],
    [nil, nil, nil, nil, "2W", nil, nil, nil, nil, nil, "2W", nil, nil, nil, nil],
    [nil, "3L", nil, nil, nil, "3L", nil, nil, nil, "3L", nil, nil, nil, "3L", nil],
    [nil, nil, "2L", nil, nil, nil, "2L", nil, "2L", nil, nil, nil, "2L", nil, nil],
    ["3W", nil, nil, "2L", nil, nil, nil, "X", nil, nil, nil, "2L", nil, nil, "3W"],
    [nil, nil, "2L", nil, nil, nil, "2L", nil, "2L", nil, nil, nil, "2L", nil, nil],
    [nil, "3L", nil, nil, nil, "3L", nil, nil, nil, "3L", nil, nil, nil, "3L", nil],
    [nil, nil, nil, nil, "2W", nil, nil, nil, nil, nil, "2W", nil, nil, nil, nil],
    ["2L", nil, nil, "2W", nil, nil, nil, "2L", nil, nil, nil, "2W", nil, nil, "2L"],
    [nil, nil, "2W", nil, nil, nil, "2L", nil, "2L", nil, nil, nil, "2W", nil, nil],
    [nil, "2W", nil, nil, nil, "3L", nil, nil, nil, "3L", nil, nil, nil, "2W", nil],
    ["3W", nil, nil, "2L", nil, nil, nil, "3W", nil, nil, nil, "2L", nil, nil, "3W"]
  ]

  def get() do
    @content
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, index_row} ->
      Enum.with_index(row)
      |> Enum.map(fn {value, index_column} ->
        {index_row, index_column, value}
      end)
    end)
  end
end
