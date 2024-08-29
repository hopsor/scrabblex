defmodule Scrabblex.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :owner, :boolean, default: false, null: false
      add :match_id, references(:matches, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :hand, :map
      add :score, :integer
      add :lock_version, :integer, default: 1

      timestamps(type: :utc_datetime)
    end

    # create index(:players, [:match_id])
    # create index(:players, [:user_id])
    create unique_index(:players, [:match_id, :user_id])
  end
end
