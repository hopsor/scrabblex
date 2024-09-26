defmodule Scrabblex.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :status, :string
      add :bag, :map
      add :lexicon_id, references(:lexicons, on_delete: :nothing), null: false
      add :turn, :integer, default: 0
      add :friendly_id, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:matches, :friendly_id)
  end
end
