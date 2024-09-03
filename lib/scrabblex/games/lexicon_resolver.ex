defmodule Scrabblex.Games.LexiconResolver do
  @moduledoc """
  LexiconResolver is responsible of matching a list of words against a lexicon.
  """
  alias Scrabblex.Repo
  alias Scrabblex.Games.{LexiconEntry, Match}

  import Ecto.Query, warn: false

  @doc """
  Returns :ok if all the entries are matched against a given lexicon

  Returns {:error, :words_not_found, unmatched_entries} when at least one of the words aren't found.
  """
  def resolve(%Match{lexicon_id: lexicon_id}, entries) do
    entries_without_dupes = Enum.uniq(entries)

    query =
      from e in LexiconEntry,
        select: e.name,
        where: e.lexicon_id == ^lexicon_id and e.name in ^entries_without_dupes

    matching_entries = Repo.all(query)

    case entries_without_dupes -- matching_entries do
      [] -> :ok
      unmatched_entries -> {:error, :words_not_found, unmatched_entries}
    end
  end
end
