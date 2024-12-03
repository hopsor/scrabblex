defmodule ScrabblexWeb.MatchLive.TileComponent do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: ScrabblexWeb.Endpoint, router: ScrabblexWeb.Router

  import ScrabblexWeb.CoreComponents, only: [icon: 1]

  def tile(assigns) do
    ~H"""
    <div
      data-id={@tile.id}
      class={[
        "tile bg-yellow-200 rounded-md aspect-square w-full h-auto relative shadow-inner",
        @draggable_class
      ]}
    >
      <div class="text-md font-bold text-center absolute inset-0 h-full w-full flex items-center justify-center select-none">
        {@tile.value}
      </div>

      <div class="text-xs text-right absolute right-0.5 bottom-0.5">{@tile.score}</div>

      <div
        :if={@tile.wildcard && !@played}
        class="absolute bg-gray-100 left-0 top-0 opacity-0 hover:opacity-80 w-full h-full text-center flex items-center justify-center cursor-pointer"
      >
        <.link patch={~p"/m/#{@friendly_id}/edit_wildcard/#{@tile}"} class="rounded-full bg-white p-2">
          <.icon name="hero-pencil" />
        </.link>
      </div>
    </div>
    """
  end
end
