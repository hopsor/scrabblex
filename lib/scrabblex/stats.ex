defmodule Scrabblex.Stats do
  import Ecto.Query, warn: false

  alias Scrabblex.Accounts.User
  alias Scrabblex.Games.{Player, Play}
  alias Scrabblex.Repo

  def played_matches_count(%User{id: user_id}) do
    query =
      from p in Player,
        where: p.user_id == ^user_id

    Repo.aggregate(query, :count)
  end

  def won_matches_count(%User{id: user_id}) do
    subquery =
      from p in Scrabblex.Games.Player,
        where: p.match_id == parent_as(:match).id,
        order_by: [desc: p.score],
        limit: 1,
        select: p.id

    query =
      from m in Scrabblex.Games.Match,
        as: :match,
        join: p in assoc(m, :players),
        where: m.status == "finished" and p.user_id == ^user_id,
        where: p.id == subquery(subquery),
        select: count(m.id)

    Repo.one(query)
  end

  def total_points(%User{id: user_id}) do
    query =
      from p in Play,
        join: player in Player,
        on: player.id == p.player_id,
        where: player.user_id == ^user_id

    Repo.aggregate(query, :sum, :score)
  end
end
