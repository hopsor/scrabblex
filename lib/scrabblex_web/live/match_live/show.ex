defmodule ScrabblexWeb.MatchLive.Show do
  use ScrabblexWeb, :live_view

  alias Scrabblex.Games

  @impl true
  def mount(%{"friendly_id" => friendly_id}, _session, socket) do
    match = Games.get_match!(friendly_id)
    events_topic = "match:#{match.id}:events"

    socket =
      socket
      |> assign(:match, match)
      |> assign(:events_topic, events_topic)
      |> assign(:presences, %{})

    socket =
      if connected?(socket) do
        presence_topic = "match:#{match.id}:online_users"

        ScrabblexWeb.Presence.track_user(presence_topic, socket.assigns.current_user.id, %{})
        ScrabblexWeb.Presence.subscribe(presence_topic)
        ScrabblexWeb.Endpoint.subscribe(events_topic)

        presences =
          ScrabblexWeb.Presence.list_online_users(presence_topic)
          |> Enum.map(&{&1.user.id, &1})
          |> Enum.into(%{})

        socket
        |> assign(:presences, presences)
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, page_title(:show))
    |> assign(:wildcard, nil)
  end

  defp apply_action(socket, :edit_wildcard, %{"wildcard_id" => wildcard_id}) do
    current_player =
      Enum.find(socket.assigns.match.players, &(&1.user_id == socket.assigns.current_user.id))

    wildcard = Enum.find(current_player.hand, &(&1.id == wildcard_id))

    socket
    |> assign(:page_title, page_title(:edit_wildcard))
    |> assign(:wildcard, wildcard)
    |> assign(:current_player, current_player)
  end

  defp apply_action(socket, :exchange_tiles, _) do
    current_player =
      Enum.find(socket.assigns.match.players, &(&1.user_id == socket.assigns.current_user.id))

    socket
    |> assign(:page_title, page_title(:exchange_tiles))
    |> assign(:current_player, current_player)
  end

  @impl true
  def handle_info({ScrabblexWeb.Presence, {:join, presence}}, socket) do
    {:noreply,
     assign(socket, :presences, Map.put(socket.assigns.presences, presence.user.id, presence))}
  end

  @impl true
  def handle_info({ScrabblexWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply,
       assign(socket, :presences, Map.delete(socket.assigns.presences, presence.user.id))}
    else
      {:noreply,
       assign(socket, :presences, Map.put(socket.assigns.presences, presence.user.id, presence))}
    end
  end

  @impl true
  def handle_info(%{event: event, payload: _payload}, socket)
      when event in ~w(player_created player_deleted match_started play_created) do
    {:noreply,
     socket
     |> assign(:match, Games.get_match!(socket.assigns.match.id))}
  end

  def handle_info({:updated_player, _player}, socket) do
    {:noreply,
     socket
     |> assign(:match, Games.get_match!(socket.assigns.match.id))}
  end

  defp page_title(:show), do: "Show Match"
  defp page_title(:edit_wildcard), do: "Edit wildcard tile"
  defp page_title(:exchange_tiles), do: "Exchange tiles"
end
