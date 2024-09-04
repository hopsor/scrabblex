defmodule Scrabblex.Games.WordScannerTest do
  use ExUnit.Case

  alias Scrabblex.Games.{Maptrix, Match, Player, Play, Tile, WordScanner}
  alias Scrabblex.Games.Position
  alias Scrabblex.Games.Word

  describe "scan/3 when the board is empty" do
    test "returns a list of Word when the tiles are horizontal" do
      existing_tiles = %{}

      new_tiles =
        %Player{
          hand: [
            %Tile{score: 1, value: "F", position: %Position{row: 7, column: 6}},
            %Tile{score: 1, value: "O", position: %Position{row: 7, column: 7}},
            %Tile{score: 1, value: "O", position: %Position{row: 7, column: 8}}
          ]
        }
        |> Maptrix.from_player()

      alignment = :horizontal

      assert WordScanner.scan(existing_tiles, new_tiles, alignment) ==
               {:ok,
                [
                  %Word{
                    value: "FOO",
                    score: 3,
                    positions: [
                      %Position{row: 7, column: 6},
                      %Position{row: 7, column: 7},
                      %Position{row: 7, column: 8}
                    ]
                  }
                ]}
    end

    test "returns a list of Word when the tiles are vertical" do
      existing_tiles = %{}

      new_tiles =
        %Player{
          hand: [
            %Tile{score: 1, value: "F", position: %Position{row: 6, column: 7}},
            %Tile{score: 1, value: "O", position: %Position{row: 7, column: 7}},
            %Tile{score: 1, value: "O", position: %Position{row: 8, column: 7}}
          ]
        }
        |> Maptrix.from_player()

      alignment = :vertical

      assert WordScanner.scan(existing_tiles, new_tiles, alignment) ==
               {:ok,
                [
                  %Word{
                    value: "FOO",
                    score: 3,
                    positions: [
                      %Position{row: 6, column: 7},
                      %Position{row: 7, column: 7},
                      %Position{row: 8, column: 7}
                    ]
                  }
                ]}
    end
  end

  describe "scan/3 when the board has tiles" do
    test "returns one or more words when the player is providing just one" do
      existing_tiles =
        %Match{
          plays: [
            %Play{
              tiles: [
                %Tile{score: 1, value: "F", position: %Position{row: 7, column: 6}},
                %Tile{score: 1, value: "O", position: %Position{row: 7, column: 7}},
                %Tile{score: 1, value: "O", position: %Position{row: 7, column: 8}}
              ],
              type: "play"
            },
            %Play{
              tiles: [
                %Tile{score: 1, value: "O", position: %Position{row: 8, column: 6}},
                %Tile{score: 1, value: "O", position: %Position{row: 9, column: 6}}
              ],
              type: "play"
            }
          ]
        }
        |> Maptrix.from_match()

      new_tiles =
        %Player{
          hand: [
            %Tile{score: 1, value: "R", position: %Position{row: 8, column: 7}}
          ]
        }
        |> Maptrix.from_player()

      alignment = :single

      assert WordScanner.scan(existing_tiles, new_tiles, alignment) ==
               {:ok,
                [
                  %Word{
                    value: "OR",
                    score: 2,
                    positions: [
                      %Position{row: 8, column: 6},
                      %Position{row: 8, column: 7}
                    ]
                  },
                  %Word{
                    value: "OR",
                    score: 2,
                    positions: [
                      %Position{row: 7, column: 7},
                      %Position{row: 8, column: 7}
                    ]
                  }
                ]}
    end

    test "returns one word when appending tiles to an existing word exclusively extending its length" do
      existing_tiles =
        %Match{
          plays: [
            %Play{
              tiles: [
                %Tile{score: 1, value: "F", position: %Position{row: 7, column: 6}},
                %Tile{score: 1, value: "O", position: %Position{row: 7, column: 7}},
                %Tile{score: 1, value: "O", position: %Position{row: 7, column: 8}}
              ],
              type: "play"
            }
          ]
        }
        |> Maptrix.from_match()

      new_tiles =
        %Player{
          hand: [
            %Tile{score: 1, value: "B", position: %Position{row: 7, column: 9}},
            %Tile{score: 1, value: "A", position: %Position{row: 7, column: 10}},
            %Tile{score: 1, value: "R", position: %Position{row: 7, column: 11}}
          ]
        }
        |> Maptrix.from_player()

      alignment = :horizontal

      assert WordScanner.scan(existing_tiles, new_tiles, alignment) ==
               {:ok,
                [
                  %Word{
                    value: "FOOBAR",
                    score: 7,
                    positions: [
                      %Position{row: 7, column: 6},
                      %Position{row: 7, column: 7},
                      %Position{row: 7, column: 8},
                      %Position{row: 7, column: 9},
                      %Position{row: 7, column: 10},
                      %Position{row: 7, column: 11}
                    ]
                  }
                ]}
    end

    test "returns one word when prepending tiles to an existing word exclusively extending its length" do
      existing_tiles =
        %Match{
          plays: [
            %Play{
              tiles: [
                %Tile{score: 1, value: "B", position: %Position{row: 7, column: 6}},
                %Tile{score: 1, value: "A", position: %Position{row: 7, column: 7}},
                %Tile{score: 1, value: "R", position: %Position{row: 7, column: 8}}
              ],
              type: "play"
            }
          ]
        }
        |> Maptrix.from_match()

      new_tiles =
        %Player{
          hand: [
            %Tile{score: 1, value: "F", position: %Position{row: 7, column: 3}},
            %Tile{score: 1, value: "O", position: %Position{row: 7, column: 4}},
            %Tile{score: 1, value: "O", position: %Position{row: 7, column: 5}}
          ]
        }
        |> Maptrix.from_player()

      alignment = :horizontal

      assert WordScanner.scan(existing_tiles, new_tiles, alignment) ==
               {:ok,
                [
                  %Word{
                    value: "FOOBAR",
                    score: 7,
                    positions: [
                      %Position{row: 7, column: 3},
                      %Position{row: 7, column: 4},
                      %Position{row: 7, column: 5},
                      %Position{row: 7, column: 6},
                      %Position{row: 7, column: 7},
                      %Position{row: 7, column: 8}
                    ]
                  }
                ]}
    end

    test "returns one word when dropping the tiles perpendiculary leveraging a letter that was already on the board" do
      existing_tiles =
        %Match{
          plays: [
            %Play{
              tiles: [
                %Tile{score: 1, value: "B", position: %Position{row: 7, column: 6}},
                %Tile{score: 1, value: "A", position: %Position{row: 7, column: 7}},
                %Tile{score: 1, value: "R", position: %Position{row: 7, column: 8}}
              ],
              type: "play"
            }
          ]
        }
        |> Maptrix.from_match()

      new_tiles =
        %Player{
          hand: [
            %Tile{score: 1, value: "C", position: %Position{row: 5, column: 8}},
            %Tile{score: 1, value: "A", position: %Position{row: 6, column: 8}}
          ]
        }
        |> Maptrix.from_player()

      alignment = :vertical

      assert WordScanner.scan(existing_tiles, new_tiles, alignment) ==
               {:ok,
                [
                  %Word{
                    value: "CAR",
                    score: 4,
                    positions: [
                      %Position{row: 5, column: 8},
                      %Position{row: 6, column: 8},
                      %Position{row: 7, column: 8}
                    ]
                  }
                ]}
    end

    test "returns two words when dropping the tiles perpendiculary extending a word that was originally played on the board" do
      existing_tiles =
        %Match{
          plays: [
            %Play{
              tiles: [
                %Tile{score: 1, value: "B", position: %Position{row: 7, column: 6}},
                %Tile{score: 1, value: "A", position: %Position{row: 7, column: 7}},
                %Tile{score: 1, value: "R", position: %Position{row: 7, column: 8}}
              ],
              type: "play"
            }
          ]
        }
        |> Maptrix.from_match()

      new_tiles =
        %Player{
          hand: [
            %Tile{score: 1, value: "S", position: %Position{row: 3, column: 9}},
            %Tile{score: 1, value: "T", position: %Position{row: 4, column: 9}},
            %Tile{score: 1, value: "A", position: %Position{row: 5, column: 9}},
            %Tile{score: 1, value: "R", position: %Position{row: 6, column: 9}},
            %Tile{score: 1, value: "S", position: %Position{row: 7, column: 9}}
          ]
        }
        |> Maptrix.from_player()

      alignment = :vertical

      assert WordScanner.scan(existing_tiles, new_tiles, alignment) ==
               {:ok,
                [
                  %Word{
                    value: "STARS",
                    score: 7,
                    positions: [
                      %Position{row: 3, column: 9},
                      %Position{row: 4, column: 9},
                      %Position{row: 5, column: 9},
                      %Position{row: 6, column: 9},
                      %Position{row: 7, column: 9}
                    ]
                  },
                  %Word{
                    value: "BARS",
                    score: 4,
                    positions: [
                      %Position{row: 7, column: 6},
                      %Position{row: 7, column: 7},
                      %Position{row: 7, column: 8},
                      %Position{row: 7, column: 9}
                    ]
                  }
                ]}
    end

    test "returns as 1 plus as many words as adyacent tiles it has with a parallel word that was originally played on the board" do
      existing_tiles =
        %Match{
          plays: [
            %Play{
              tiles: [
                %Tile{score: 1, value: "B", position: %Position{row: 7, column: 6}},
                %Tile{score: 1, value: "A", position: %Position{row: 7, column: 7}},
                %Tile{score: 1, value: "R", position: %Position{row: 7, column: 8}}
              ],
              type: "play"
            },
            %Play{
              tiles: [
                %Tile{score: 1, value: "N", position: %Position{row: 0, column: 8}},
                %Tile{score: 1, value: "O", position: %Position{row: 1, column: 8}},
                %Tile{score: 1, value: "V", position: %Position{row: 2, column: 8}},
                %Tile{score: 1, value: "E", position: %Position{row: 3, column: 8}},
                %Tile{score: 1, value: "M", position: %Position{row: 4, column: 8}},
                %Tile{score: 1, value: "B", position: %Position{row: 5, column: 8}},
                %Tile{score: 1, value: "E", position: %Position{row: 6, column: 8}}
              ],
              type: "play"
            }
          ]
        }
        |> Maptrix.from_match()

      new_tiles =
        %Player{
          hand: [
            %Tile{score: 1, value: "I", position: %Position{row: 0, column: 7}},
            %Tile{score: 1, value: "N", position: %Position{row: 1, column: 7}},
            %Tile{score: 1, value: "A", position: %Position{row: 2, column: 7}},
            %Tile{score: 1, value: "R", position: %Position{row: 3, column: 7}}
          ]
        }
        |> Maptrix.from_player()

      alignment = :vertical

      assert WordScanner.scan(existing_tiles, new_tiles, alignment) ==
               {:ok,
                [
                  %Word{
                    id: nil,
                    score: 15,
                    value: "INAR",
                    positions: [
                      %Position{row: 0, column: 7},
                      %Position{row: 1, column: 7},
                      %Position{row: 2, column: 7},
                      %Position{row: 3, column: 7}
                    ]
                  },
                  %Word{
                    id: nil,
                    score: 6,
                    value: "IN",
                    positions: [
                      %Position{row: 0, column: 7},
                      %Position{row: 0, column: 8}
                    ]
                  },
                  %Word{
                    id: nil,
                    value: "NO",
                    score: 2,
                    positions: [
                      %Position{row: 1, column: 7},
                      %Position{row: 1, column: 8}
                    ]
                  },
                  %Word{
                    id: nil,
                    value: "AV",
                    score: 2,
                    positions: [
                      %Position{row: 2, column: 7},
                      %Position{row: 2, column: 8}
                    ]
                  },
                  %Word{
                    id: nil,
                    value: "RE",
                    score: 3,
                    positions: [
                      %Position{row: 3, column: 7},
                      %Position{row: 3, column: 8}
                    ]
                  }
                ]}
    end
  end
end
