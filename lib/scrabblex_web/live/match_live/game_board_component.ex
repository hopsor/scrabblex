defmodule ScrabblexWeb.MatchLive.GameBoardComponent do
  use ScrabblexWeb, :live_component

  alias Scrabblex.Games
  alias Scrabblex.Games.{Maptrix, Match, Player}
  alias ScrabblexWeb.MatchLive.TileComponent
  alias ScrabblexWeb.MatchLive.PlayLog

  @impl true
  def render(assigns) do
    ~H"""
    <div id="game_board" phx-hook="Drag" phx-target={@myself}>
      <div
        :if={!@current_player}
        class="bg-gradient-to-b from-green-500 bg-green-400 border-b text-white font-semibold text-center py-2"
      >
        <.icon name="hero-tv" /> Viewer mode
      </div>
      <div class="bg-white shadow">
        <div class="max-w-7xl mx-auto grid grid-cols-3 px-4">
          <div class="col-span-2 grid grid-cols-4">
            <div
              :for={player <- @match.players}
              class={[
                "flex flex-col border-l last:border-r pt-1",
                @player_on_turn == player && @match.status != "finished" &&
                  "bg-gray-100 animate-pulse"
              ]}
            >
              <div class="flex items-stretch">
                <div class="grow h-auto flex flex-col items-center justify-center my-2">
                  <.avatar user={player.user} />
                  <div class="text-sm font-semibold leading-6 text-center text-gray-500">
                    <%= player.user.name %>
                  </div>
                </div>
                <div class="grow h-auto flex flex-col items-center justify-center">
                  <p class="text-2xl font-bold text-center text-gray-600">
                    <%= player.score %>
                  </p>
                  <p class="text-xs text-center text-gray-400">points</p>
                </div>
              </div>
            </div>
          </div>

          <div class="grid grid-cols-3">
            <div>
              <div class="grow h-full flex flex-col items-center justify-center">
                <p class="text-xs text-center text-gray-300 font-bold">TURN #</p>
                <p class="text-2xl font-bold text-center text-gray-600">
                  <%= @match.turn + 1 %>
                </p>
              </div>
            </div>

            <div>
              <div class="grow h-full flex flex-col items-center justify-center">
                <p class="text-xs text-center text-gray-300 font-bold">TILES LEFT</p>
                <p class="text-2xl font-bold text-center text-gray-600">
                  <%= length(@match.bag) %>
                </p>
              </div>
            </div>

            <div>
              <div class="grow h-full flex flex-col items-center justify-center">
                <p class="text-xs text-center text-gray-300 font-bold">LEXICON</p>
                <p class="text-2xl font-bold text-center text-gray-600">
                  <%= @match.lexicon.name %>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4">
        <div class="flex flex-row">
          <div class="basis-8/12 py-4 pr-4">
            <div id="board_wrapper" class="grid grid-cols-15 gap-1">
              <%= for {row, column, booster, tile, played} <- @board_cells do %>
                <.live_component
                  module={ScrabblexWeb.MatchLive.BoardSlotComponent}
                  row={row}
                  column={column}
                  booster={booster}
                  id={"slot_#{row}_#{column}"}
                  tile={tile}
                  played={played}
                  friendly_id={@match.friendly_id}
                />
              <% end %>
            </div>
          </div>
          <div class="basis-4/12">
            <div
              :if={@current_player}
              id="hand"
              class="grid grid-cols-7 gap-2 dropzone min-w-full max-w-md mx-auto mt-4"
            >
              <TileComponent.tile
                :for={tile <- @parked_tiles}
                tile={tile}
                friendly_id={@match.friendly_id}
                draggable_class="draggable"
                played={false}
              />
            </div>
            <div
              :if={@current_player && @match.status != "finished"}
              id="actions"
              class="mt-5 text-center"
            >
              <.button
                :if={@can_submit}
                id="btn_submit_play"
                phx-click="submit_play"
                phx-target={@myself}
                title="Submit play"
              >
                <.icon name="hero-check-circle" />
              </.button>
              <.button
                :if={@can_submit}
                id="btn_skip_turn"
                phx-click="skip_turn"
                phx-target={@myself}
                data-confirm="Are you sure you want to skip?"
                title="Skip turn"
              >
                <.icon name="hero-x-mark" />
              </.button>
              <.button :if={@can_exchange} id="btn_exchange_tiles" title="Exchange tiles">
                <.link patch={~p"/m/#{@match}/exchange_tiles"}>
                  <.icon name="hero-arrow-path-rounded-square" />
                </.link>
              </.button>
              <.button
                class="p-1"
                id="btn_shuffle"
                phx-click="shuffle"
                phx-target={@myself}
                title="Shuffle tiles"
              >
                <.icon name="hero-arrows-right-left" />
              </.button>
              <.button
                id="btn_recover"
                phx-click="recover"
                phx-target={@myself}
                title="Recover tiles from board"
              >
                <.icon name="hero-inbox-arrow-down" />
              </.button>
            </div>
            <!-- Play history div -->
            <div
              id="play_log"
              class="rounded-md bg-white p-3 my-4 text-gray-500 h-96 overflow-scroll mt-4"
            >
              <div class="text-xl pb-3 text-gray-400 font-bold">Play log</div>
              <p :if={@match.plays == []} class="text-center py-5">The game just started!</p>
              <div :for={play <- @match.plays} class="border-b mb-1 pb-1 px-1 text-xs">
                <PlayLog.play :if={play.type == "play"} play={play} />
                <PlayLog.skip :if={play.type == "skip"} play={play} />
                <PlayLog.exchange :if={play.type == "exchange"} play={play} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    board_cells = board_cells()
    {:ok, assign(socket, :board_cells, board_cells) |> assign(:wildcard, nil)}
  end

  @impl true
  def update(%{match: match, current_user: current_user, events_topic: events_topic}, socket) do
    current_player_tuple =
      match.players
      |> Enum.with_index()
      |> Enum.find(fn {player, _index} ->
        player.user_id == current_user.id
      end)

    turn_index = rem(match.turn, length(match.players))
    player_on_turn = Enum.at(match.players, turn_index)

    custom_assigns =
      case current_player_tuple do
        nil ->
          [current_player: nil, board_cells: board_cells(match, nil)]

        {current_player, current_player_index} ->
          can_submit = turn_index == current_player_index
          can_exchange = can_submit && length(match.bag) > 0

          [
            current_player: current_player,
            can_submit: can_submit,
            can_exchange: can_exchange,
            parked_tiles: Enum.filter(current_player.hand, &is_nil(&1.position)),
            board_cells: board_cells(match, current_player)
          ]
      end

    {:ok,
     socket
     |> assign(:match, match)
     |> assign(:events_topic, events_topic)
     |> assign(:player_on_turn, player_on_turn)
     |> assign(custom_assigns)}
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
    with {:ok, %{play: play}} <-
           Games.create_play(socket.assigns.match, socket.assigns.current_player) do
      ScrabblexWeb.Endpoint.broadcast(socket.assigns.events_topic, "play_created", play)

      {:noreply, socket}
    else
      error ->
        {:noreply, put_flash!(socket, :error, submit_play_error_message(error))}
    end
  end

  def handle_event("skip_turn", _, socket) do
    with {:ok, %{play: play}} <-
           Games.skip_turn(socket.assigns.match, socket.assigns.current_player) do
      ScrabblexWeb.Endpoint.broadcast(socket.assigns.events_topic, "play_created", play)

      {:noreply, socket}
    else
      error ->
        {:noreply, put_flash!(socket, :error, submit_play_error_message(error))}
    end
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
         |> push_navigate(to: ~p"/m/#{socket.assigns.match}")}
    end
  end

  defp board_cells() do
    Scrabblex.Games.BoardLayout.get()
    |> Enum.map(fn {row, column, booster} ->
      {row, column, booster, nil, nil}
    end)
  end

  defp board_cells(%Match{} = match, %Player{} = player) do
    plays_matrix = Maptrix.from_match(match)
    player_matrix = Maptrix.from_player(player)

    board_cells()
    |> Enum.map(fn {row, column, booster, _, _} ->
      {tile, played} =
        case Map.get(plays_matrix, {row, column}) do
          nil ->
            {Map.get(player_matrix, {row, column}), false}

          tile_played ->
            {tile_played, true}
        end

      {row, column, booster, tile, played}
    end)
  end

  defp board_cells(%Match{} = match, nil) do
    plays_matrix = Maptrix.from_match(match)

    board_cells()
    |> Enum.map(fn {row, column, booster, _, _} ->
      {row, column, booster, Map.get(plays_matrix, {row, column}), true}
    end)
  end

  # TODO: Consider using gettext
  defp submit_play_error_message({:error, :empty_play}) do
    "You must put some tiles on the board!"
  end

  defp submit_play_error_message({:error, :contiguity_error}) do
    "All tiles should be adjacent"
  end

  defp submit_play_error_message({:error, :center_not_found}) do
    "At the beginning the first word must cross the center of the board"
  end

  defp submit_play_error_message({:error, :words_not_found, words}) do
    formatted_words = Enum.join(words, ", ")
    "Invalid words: #{formatted_words}"
  end

  defp submit_play_error_message(_) do
    "Unknown error"
  end
end
