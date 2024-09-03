defmodule Scrabblex.Games.LexiconResolverTest do
  # use ExUnit.Case
  use ScrabblexWeb.ConnCase

  alias Scrabblex.Games.{Match, LexiconResolver}
  import Scrabblex.GamesFixtures

  describe "resolve/2" do
    setup do
      lexicon = lexicon_fixture()
      {:ok, %{lexicon: lexicon}}
    end

    test "returns :ok when all the words are found within the match lexicon", %{lexicon: lexicon} do
      lexicon_entry_fixture(%{name: "FOO", lexicon_id: lexicon.id})
      lexicon_entry_fixture(%{name: "BAR", lexicon_id: lexicon.id})
      lexicon_entry_fixture(%{name: "BAZ", lexicon_id: lexicon.id})

      assert LexiconResolver.resolve(%Match{lexicon_id: lexicon.id}, [
               %Word{value: "FOO"},
               %Word{value: "BAR"},
               %Word{value: "BAZ"}
             ]) == :ok
    end

    test "returns {:error, :words_not_found, words} when some words aren't found within the match lexicon",
         %{lexicon: lexicon} do
      lexicon_entry_fixture(%{name: "FOO", lexicon_id: lexicon.id})
      lexicon_entry_fixture(%{name: "BAZ", lexicon_id: lexicon.id})

      assert LexiconResolver.resolve(%Match{lexicon_id: lexicon.id}, [
               %Word{value: "FOO"},
               %Word{value: "BAR"},
               %Word{value: "BAZ"}
             ]) ==
               {:error, :words_not_found, ~w(BAR)}
    end
  end
end
