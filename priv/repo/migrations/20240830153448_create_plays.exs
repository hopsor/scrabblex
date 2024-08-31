defmodule Scrabblex.Repo.Migrations.CreatePlays do
  use Ecto.Migration

  def change do
    create table(:plays) do
      add :tiles, :map, null: false
      add :words, :map, null: false
      add :score, :integer, null: false
      add :turn, :integer, null: false
      add :type, :string, null: false
      add :player_id, references(:players, on_delete: :nothing), null: false
      add :match_id, references(:matches, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:plays, [:player_id])
    create index(:plays, [:match_id])
    create unique_index(:plays, [:match_id, :turn])
  end
end
