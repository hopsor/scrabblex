defmodule ScrabblexWeb.MatchLive.LobbyComponent do
  use ScrabblexWeb, :live_component

  alias Scrabblex.Games
  alias Scrabblex.Games.Player
  alias ScrabblexWeb.MatchLive.LobbyState

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Lobby</h1>

      <div id="lobby_users">
        <div
          :for={lobby_user <- @lobby_users}
          id={"lobby_user_#{lobby_user.user.id}"}
          class="flex min-w-0 gap-x-4"
        >
          <div class="relative flex-none">
            <img
              class="w-10 h-10 rounded-full"
              src="https://flowbite.com/docs/images/people/profile-picture-5.jpg"
              alt=""
            />
            <span class={[
              "bottom-0 left-7 absolute w-3.5 h-3.5 border-2 border-white dark:border-gray-800 rounded-full",
              lobby_user.online == true && "bg-green-400 online",
              lobby_user.online == false && "bg-red-400 offline"
            ]}>
            </span>
          </div>

          <div class="min-w-0 flex-auto">
            <p class="text-sm font-semibold leading-6 text-gray-900">
              <%= lobby_user.user.name %>
            </p>

            <span
              :if={lobby_user.owner}
              class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20"
            >
              Owner
            </span>
          </div>

          <div :if={lobby_user.joined}>
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

  defp broadcast(events_topic, event, payload) do
    ScrabblexWeb.Endpoint.broadcast(events_topic, event, payload)
  end
end
