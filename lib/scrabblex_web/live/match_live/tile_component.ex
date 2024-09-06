defmodule ScrabblexWeb.MatchLive.TileComponent do
  use Phoenix.Component

  def tile(assigns) do
    ~H"""
    <div
      data-id={@tile.id}
      class={[
        "tile bg-yellow-200 rounded-md aspect-square w-full h-auto relative shadow-inner",
        @draggable_class
      ]}
    >
      <div class="text-md font-bold text-center absolute inset-0 h-full w-full flex items-center justify-center">
        <%= @tile.value %>
      </div>
      <div class="text-xs text-right absolute right-0.5 top-0.5"><%= @tile.score %></div>
    </div>
    """
  end
end
