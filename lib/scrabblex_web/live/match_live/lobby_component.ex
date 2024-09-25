defmodule ScrabblexWeb.MatchLive.LobbyComponent do
  use ScrabblexWeb, :live_component

  alias Scrabblex.Games
  alias Scrabblex.Games.Player
  alias ScrabblexWeb.MatchLive.LobbyState

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="bg-white shadow">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <.header>New Match: Lobby</.header>
        </div>
      </div>

      <div id="lobby_users" class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
        <div class="bg-white rounded-lg mb-4">
          <div
            :for={lobby_user <- @lobby_users}
            id={"lobby_user_#{lobby_user.user.id}"}
            class="flex min-w-0 gap-x-4 p-4 border-b border-gray-200 items-center last:border-b-0"
            phx-mounted={
              JS.transition({"ease-in duration-500", "opacity-0", "opacity-100"}, time: 500)
            }
            phx-remove={
              JS.transition({"ease-out duration-500", "opacity-100", "opacity-0"}, time: 500)
            }
          >
            <.avatar user={lobby_user.user} online={lobby_user.online} />

            <div class="min-w-0 flex-auto">
              <p class="text-sm font-semibold leading-6 text-gray-900">
                <%= lobby_user.user.name %>
              </p>

              <span
                :if={lobby_user.owner}
                class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20"
              >
                Owner
              </span>
            </div>

            <div
              :if={lobby_user.joined}
              class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20"
            >
              <.icon name="hero-check" /> Joined
            </div>
          </div>
        </div>
        <button
          :if={@joinable?}
          id="btn_join"
          phx-click="join"
          phx-disable-with="Joining..."
          phx-target={@myself}
          class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        >
          Join
        </button>
        <button
          :if={@leavable?}
          id="btn_leave"
          phx-click="leave"
          phx-disable-with="Leaving..."
          phx-target={@myself}
          class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        >
          Leave
        </button>
        <button
          :if={@startable?}
          phx-click="start"
          phx-disable-with="Starting..."
          phx-target={@myself}
          class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        >
          Start
        </button>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    players = assigns.match.players
    presences = assigns.presences

    joinable =
      length(players) < 4 and Enum.all?(players, &(&1.user_id != assigns.current_user.id))

    leavable = Enum.any?(players, &(&1.user_id == assigns.current_user.id && !&1.owner))

    startable =
      length(players) > 1 &&
        Enum.any?(players, &(&1.user_id == assigns.current_user.id && &1.owner))

    {:ok,
     assign(
       socket,
       Map.merge(assigns, %{
         joinable?: joinable,
         leavable?: leavable,
         startable?: startable,
         lobby_users: LobbyState.compute(players, presences)
       })
     )}
  end

  @impl true
  def handle_event("join", _params, socket) do
    join_match(socket)
  end

  @impl true
  def handle_event("leave", _params, socket) do
    leave_match(socket)
  end

  @impl true
  def handle_event("start", _params, socket) do
    start_match(socket)
  end

  defp join_match(socket) do
    match_id = socket.assigns.match.id
    user_id = socket.assigns.current_user.id
    events_topic = socket.assigns.events_topic

    case Games.create_player(%{match_id: match_id, user_id: user_id, owner: false}) do
      {:ok, player} ->
        broadcast(events_topic, "player_created", player)

        {:noreply, socket |> put_flash(:info, "Joined successfully")}

      _error ->
        {:noreply, put_flash(socket, :error, "Something went wrong")}
    end
  end

  defp leave_match(socket) do
    user_id = socket.assigns.current_user.id
    events_topic = socket.assigns.events_topic
    player = Enum.find(socket.assigns.match.players, &(&1.user_id == user_id))

    case Games.delete_player(%Player{id: player.id}) do
      {:ok, player} ->
        broadcast(events_topic, "player_deleted", player)

        {:noreply, socket |> put_flash(:info, "Left successfully")}

      _error ->
        {:noreply, put_flash(socket, :error, "Something went wrong")}
    end
  end

  def start_match(socket) do
    match = socket.assigns.match
    events_topic = socket.assigns.events_topic

    case Games.start_match(match) do
      {:ok, match} ->
        broadcast(events_topic, "match_started", match)

        {:noreply, socket |> put_flash(:info, "Game started!")}

      _error ->
        {:noreply, put_flash(socket, :error, "Something went wrong")}
    end
  end

  defp broadcast(events_topic, event, payload) do
    ScrabblexWeb.Endpoint.broadcast(events_topic, event, payload)
  end
end
