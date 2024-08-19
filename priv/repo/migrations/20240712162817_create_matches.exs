defmodule Scrabblex.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :dictionary, :string
      add :status, :string
      add :bag, :map

      timestamps(type: :utc_datetime)
    end
  end
end
