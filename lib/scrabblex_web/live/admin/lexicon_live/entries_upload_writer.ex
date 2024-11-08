defmodule ScrabblexWeb.Admin.LexiconLive.EntriesUploadWriter do
  @behaviour Phoenix.LiveView.UploadWriter

  alias Scrabblex.Repo
  alias Scrabblex.Games.LexiconEntry

  require Logger

  @impl true
  def init(opts) do
    lexicon_id = Keyword.get(opts, :lexicon_id)

    {:ok,
     %{
       total: 0,
       chunk_counter: 0,
       words_counter: 0,
       lexicon_id: lexicon_id,
       pending_word: ""
     }}
  end

  @impl true
  def meta(state), do: %{chunk_counter: state.chunk_counter, words_counter: state.words_counter}

  @impl true
  def write_chunk(data, state) do
    size = byte_size(data)
    Logger.log(:info, "received chunk of #{size} bytes")

    {full_words, new_pending_word} = extract_words(state.pending_word, data)

    lexicon_entries =
      Enum.map(full_words, &%{lexicon_id: state.lexicon_id, name: String.upcase(&1)})

    Repo.insert_all(
      LexiconEntry,
      lexicon_entries
    )

    {:ok,
     %{
       state
       | total: state.total + size,
         chunk_counter: state.chunk_counter + 1,
         pending_word: new_pending_word,
         words_counter: state.words_counter + Enum.count(full_words)
     }}
  end

  @impl true
  def close(state, reason) do
    if state.pending_word != "" do
      Repo.insert_all(LexiconEntry, [
        %{
          lexicon_id: state.lexicon_id,
          name: String.upcase(state.pending_word)
        }
      ])
    end

    Logger.log(:info, "closing upload after #{state.total} bytes}, #{inspect(reason)}")
    Logger.log(:info, "#{state.words_counter} words have been inserted in the database")

    {:ok, state}
  end

  defp extract_words(pending_word, data) do
    [first_word | rest] = String.split(data)
    words = [pending_word <> first_word] ++ rest

    if String.match?(data, ~r/(\r)?\n$/) do
      {words, ""}
    else
      incomplete_word = List.last(words)
      {words -- [incomplete_word], incomplete_word}
    end
  end
end
