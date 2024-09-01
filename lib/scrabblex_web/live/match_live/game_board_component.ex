defmodule ScrabblexWeb.MatchLive.GameBoardComponent do
  use ScrabblexWeb, :live_component

  alias Scrabblex.Games
  alias ScrabblexWeb.MatchLive.TileComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div id="game_board" phx-hook="Drag" phx-target={@myself}>
      <.header>Game Board</.header>

      <div class="max-w-5xl mx-auto">
        <div class="flex flex-row">
          <div class="basis-8/12 p-4">
            <div id="board_wrapper" class="grid grid-cols-15 gap-1">
              <%= for {row, column, value} <- @board_layout do %>
                <.live_component
                  module={ScrabblexWeb.MatchLive.BoardSlotComponent}
                  row={row}
                  column={column}
                  value={value}
                  hand={@current_player.hand}
                  id={"slot_#{row}_#{column}"}
                />
              <% end %>
            </div>

            <div id="hand" class="grid grid-cols-7 gap-2 dropzone min-w-full max-w-md mx-auto mt-5">
              <TileComponent.tile :for={tile <- @parked_tiles} tile={tile} />
            </div>

            <div id="actions" class="mt-5 text-center">
              <.button
                :if={@can_submit}
                id="btn_submit_play"
                phx-click="submit_play"
                phx-target={@myself}
              >
                <.icon name="hero-check-circle" /> Submit word
              </.button>
              <.button id="btn_shuffle" phx-click="shuffle" phx-target={@myself}>
                <.icon name="hero-arrows-right-left" /> Shuffle tiles
              </.button>
              <.button id="btn_recover" phx-click="recover" phx-target={@myself}>
                <.icon name="hero-inbox-arrow-down" /> Recover
              </.button>
            </div>
          </div>
          <div class="basis-4/12">
            <div class="rounded-md bg-white p-4 my-4">
              <!-- Score div -->
              <div class="grid grid-cols-2">
                <div :for={player <- @match.players} class="flex items-stretch">
                  <div class="flex-none w-12">
                    <img
                      class="w-12 h-12 rounded-full"
                      src="https://flowbite.com/docs/images/people/profile-picture-5.jpg"
                      alt=""
                    />
                    <p class="text-sm font-semibold leading-6 text-center mt-1 text-gray-600">
                      <%= player.user.name %>
                    </p>
                  </div>
                  <div class="grow h-auto flex flex-col items-center justify-center">
                    <p class="text-2xl font-bold text-center text-gray-600">
                      <%= player.score %>
                    </p>
                    <p class="text-xs text-center text-gray-400">points</p>
                  </div>
                </div>
              </div>
              <!-- Play history div -->
              <div></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    board_layout = Scrabblex.Games.BoardLayout.get()
    {:ok, assign(socket, :board_layout, board_layout)}
  end

  @impl true
  def update(%{match: match, current_user: current_user}, socket) do
    {current_player, current_player_index} =
      match.players
      |> Enum.with_index()
      |> Enum.find(fn {player, _index} ->
        player.user_id == current_user.id
      end)

    parked_tiles = Enum.filter(current_player.hand, &is_nil(&1.position))

    can_submit = rem(match.turn, length(match.players)) == current_player_index

    {:ok,
     socket
     |> assign(:current_player, current_player)
     |> assign(:parked_tiles, parked_tiles)
     |> assign(:match, match)
     |> assign(:can_submit, can_submit)}
  end

  @impl true
  def handle_event(
        "drop_tile",
        %{"id" => tile_id, "boardPosition" => %{"row" => row, "column" => column}},
        socket
      ) do
    current_player = socket.assigns.current_player

    hand_changesets =
      Enum.map(current_player.hand, fn tile ->
        if tile.id == tile_id do
          Games.change_tile(tile, %{position: %{row: row, column: column}})
        else
          Games.change_tile(tile)
        end
      end)

    submit_player_update(socket, hand_changesets)
  end

  def handle_event(
        "drop_tile",
        %{"id" => tile_id, "handIndex" => new_index},
        socket
      ) do
    current_player = socket.assigns.current_player

    current_index = Enum.find_index(current_player.hand, &(&1.id == tile_id))
    tile = Enum.find(current_player.hand, &(&1.id == tile_id))

    reordered_hand =
      current_player.hand
      |> List.delete_at(current_index)
      |> List.insert_at(new_index, tile)

    hand_changesets =
      Enum.map(reordered_hand, fn tile ->
        if tile.id == tile_id do
          Games.change_tile(tile, %{position: nil})
        else
          Games.change_tile(tile)
        end
      end)

    submit_player_update(socket, hand_changesets)
  end

  def handle_event("shuffle", _params, socket) do
    hand = socket.assigns.current_player.hand

    hand_changesets =
      hand
      |> Enum.shuffle()
      |> Enum.map(&Games.change_tile/1)

    submit_player_update(socket, hand_changesets)
  end

  def handle_event("recover", _params, socket) do
    hand = socket.assigns.current_player.hand

    hand_changesets =
      hand
      |> Enum.map(&Games.change_tile(&1, %{position: nil}))

    submit_player_update(socket, hand_changesets)
  end

  def handle_event("submit_play", _, socket) do
    {:noreply, socket}
  end

  defp submit_player_update(socket, hand_changesets) do
    current_player = socket.assigns.current_player

    with {:ok, player} <- Games.update_player_hand(current_player, hand_changesets) do
      send(self(), {:updated_player, player})
      {:noreply, socket}
    else
      {:error, :stale_player} ->
        {:noreply,
         socket
         |> put_flash(:error, "Your data was stale. Reloading the page to fetch fresh data")
         |> push_navigate(to: ~p"/matches/#{socket.assigns.match}")}
    end
  end
end
