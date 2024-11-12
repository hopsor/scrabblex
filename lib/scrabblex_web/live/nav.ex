defmodule ScrabblexWeb.Nav do
  import Phoenix.LiveView
  use Phoenix.Component

  alias ScrabblexWeb.DashboardLive
  alias ScrabblexWeb.MatchLive.{Index, Show}

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:active_tab, :handle_params, &handle_active_tab_params/3)}
  end

  defp handle_active_tab_params(_params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {match_live, _} when match_live in [Index, Show] ->
          :match

        {dashboard_live, _} when dashboard_live in [DashboardLive] ->
          :dashboard

        {_, _} ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
