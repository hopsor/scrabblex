defmodule Scrabblex.Games.LexiconResolver do
  alias Scrabblex.Repo
  alias Scrabblex.Games.{LexiconEntry, Match}

  import Ecto.Query, warn: false

  def resolve(%Match{lexicon_id: lexicon_id}, words) do
    word_values = Enum.map(words, & &1.value)

    query =
      from e in LexiconEntry,
        select: e.name,
        where: e.lexicon_id == ^lexicon_id and e.name in ^words

    matching_entries = Repo.all(query)

    case word_values -- matching_entries do
      [] -> :ok
      unmatched_entries -> {:error, :words_not_found, unmatched_entries}
    end
  end
end
