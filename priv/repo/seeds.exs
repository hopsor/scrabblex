# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Scrabblex.Repo.insert!(%Scrabblex.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Scrabblex.Accounts.register_user(%{email: "john@doe.org", password: "foobar", name: "john"})
