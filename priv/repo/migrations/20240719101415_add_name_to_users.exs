defmodule Scrabblex.Repo.Migrations.AddNameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :citext, null: false
    end

    create unique_index(:users, :name)
  end
end
