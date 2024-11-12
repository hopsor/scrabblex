defmodule ScrabblexWeb.UserProfileLive do
  use ScrabblexWeb, :live_view

  alias Scrabblex.{Accounts, Games, Stats}

  @impl true
  def mount(%{"name" => name}, _, socket) do
    user = Accounts.get_user_by_name(name)
    matches = Games.list_match_history(user)
    played_count = Stats.played_matches_count(user)
    won_count = Stats.won_matches_count(user)
    points = Stats.total_points(user)

    {:ok,
     socket
     |> stream(:matches, matches)
     |> assign(user: user, played_count: played_count, points: points, won_count: won_count)}
  end
end
