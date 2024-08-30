defmodule Scrabblex.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :status, :string
      add :bag, :map
      add :lexicon_id, references(:lexicons, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
