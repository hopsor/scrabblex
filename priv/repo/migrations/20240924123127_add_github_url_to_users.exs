defmodule Scrabblex.Repo.Migrations.AddGithubUrlToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :github_url, :string
    end
  end
end
