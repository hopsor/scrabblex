defmodule Scrabblex.Repo.Migrations.CreateLexicons do
  use Ecto.Migration

  def change do
    create table(:lexicons) do
      add :name, :string
      add :language, :string
      add :flag, :string
      add :enabled, :boolean, default: false
      add :bag_definitions, :map
    end

    create unique_index(:lexicons, [:name])
  end
end
