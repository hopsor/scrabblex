defmodule ScrabblexWeb.MatchLive.ExchangeTilesComponent do
  use ScrabblexWeb, :live_component

  alias Scrabblex.Games
  alias ScrabblexWeb.MatchLive.TileComponent

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Exchange tiles
        <:subtitle>Pick the tiles you want to exchange</:subtitle>
      </.header>

      <div id="choices" class="grid grid-cols-7 gap-4 mt-5">
        <div
          :for={tile <- @current_player.hand}
          phx-click="toggle_tile"
          phx-target={@myself}
          phx-value-tile-id={tile.id}
          class={["rounded-md cursor-pointer", tile in @selected_tiles && "outline outline-blue-600"]}
        >
          <TileComponent.tile
            tile={tile}
            friendly_id={@match.friendly_id}
            draggable_class=""
            played={true}
          />
        </div>
      </div>

      <div class="mt-5">
        <.button
          id="submit_exchange"
          phx-click="submit"
          phx-target={@myself}
          disabled={@selected_tiles == []}
        >
          Submit exchange
        </.button>
        <.button>
          <.link patch={~p"/m/#{@match}"}>Cancel</.link>
        </.button>
      </div>
    </div>
    """
  end

  def update(params, socket) do
    updated_params = Map.merge(params, %{selected_tiles: []})
    {:ok, assign(socket, updated_params)}
  end

  def handle_event("toggle_tile", %{"tile-id" => tile_id}, socket) do
    hand = socket.assigns.current_player.hand
    current_tiles = socket.assigns.selected_tiles
    tile = Enum.find(hand, &(&1.id == tile_id))

    selected_tiles =
      if tile in current_tiles do
        current_tiles -- [tile]
      else
        current_tiles ++ [tile]
      end

    {:noreply, assign(socket, :selected_tiles, selected_tiles)}
  end

  def handle_event("submit", _, socket) do
    selected_tiles = socket.assigns.selected_tiles

    with {:ok, %{play: play}} <-
           Games.exchange_tiles(
             socket.assigns.match,
             socket.assigns.current_player,
             selected_tiles
           ) do
      ScrabblexWeb.Endpoint.broadcast(socket.assigns.events_topic, "play_created", play)

      {:noreply,
       socket
       |> put_flash!(:info, "Exchange succeeded!")
       |> push_patch(to: ~p"/m/#{socket.assigns.match}")}
    else
      _error ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong")
         |> push_navigate(to: ~p"/m/#{socket.assigns.match}")}
    end
  end
end
