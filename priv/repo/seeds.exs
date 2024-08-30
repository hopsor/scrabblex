# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Scrabblex.Repo.insert!(%Scrabblex.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Scrabblex.Games.{Lexicon, LexiconEntry}

Scrabblex.Accounts.register_user(%{email: "john@scrabblex.org", password: "foobar", name: "john"})
Scrabblex.Accounts.register_user(%{email: "jane@scrabblex.org", password: "foobar", name: "jane"})

fise_changeset = Lexicon.changeset(%Lexicon{}, %{name: "FISE-2", language: "es", flag: "🇪🇦"})
{:ok, fise_lexicon} = Scrabblex.Repo.insert(fise_changeset)

"priv/repo/lexicons/fise-2.txt"
|> File.stream!()
|> Stream.chunk_every(500)
|> Stream.each(fn chunk ->
  batch = Enum.map(chunk, &[name: String.trim(&1), lexicon_id: fise_lexicon.id])
  Scrabblex.Repo.insert_all(LexiconEntry, batch)
end)
|> Enum.map(fn _ -> :ok end)
