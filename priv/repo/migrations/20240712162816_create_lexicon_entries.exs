defmodule Scrabblex.Repo.Migrations.CreateLexiconEntries do
  use Ecto.Migration

  def change do
    create table(:lexicon_entries) do
      add :name, :string
      add :lexicon_id, references(:lexicons, on_delete: :nothing)
    end

    create index(:lexicon_entries, [:lexicon_id, :name])
  end
end
