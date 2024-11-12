defmodule ScrabblexWeb.DashboardLive do
  use ScrabblexWeb, :live_view

  alias Scrabblex.{Games, Stats}

  def mount(_, _, socket) do
    matches = Games.list_match_history(socket.assigns.current_user)
    played_count = Stats.played_matches_count(socket.assigns.current_user)
    won_count = Stats.won_matches_count(socket.assigns.current_user)
    points = Stats.total_points(socket.assigns.current_user)

    {:ok,
     socket
     |> stream(:matches, matches)
     |> assign(played_count: played_count, points: points, won_count: won_count)}
  end
end
