defmodule ScrabblexWeb.MatchLive.Show do
  use ScrabblexWeb, :live_view

  alias Scrabblex.Games

  @impl true
  def mount(%{"id" => match_id}, _session, socket) do
    events_topic = "match:#{match_id}:events"

    socket =
      socket
      |> assign(:events_topic, events_topic)
      |> assign(:presences, %{})

    socket =
      if connected?(socket) do
        presence_topic = "match:#{match_id}:online_users"

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
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:match, Games.get_match!(id))}
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
  defp page_title(:edit), do: "Edit Match"
end
