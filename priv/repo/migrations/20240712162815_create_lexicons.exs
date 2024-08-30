defmodule Scrabblex.Repo.Migrations.CreateLexicons do
  use Ecto.Migration

  def change do
    create table(:lexicons) do
      add :name, :string
      add :language, :string
      add :flag, :string
    end

    create unique_index(:lexicons, [:name])
  end
end
