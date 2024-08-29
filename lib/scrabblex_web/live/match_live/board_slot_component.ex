defmodule ScrabblexWeb.MatchLive.BoardSlotComponent do
  use ScrabblexWeb, :live_component

  alias ScrabblexWeb.MatchLive.TileComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class={[
        "slot aspect-square h-auto flex items-center justify-center rounded-lg relative",
        @background,
        "dropzone"
      ]}
      data-row={@row}
      data-column={@column}
    >
      <div :if={@value} class="absolute text-white font-bold">
        <%= @value %>
      </div>
      <TileComponent.tile :if={@tile} tile={@tile} />
    </div>
    """
  end

  @impl true
  def update(%{value: value, row: row, column: column, hand: hand}, socket) do
    background =
      case value do
        "3W" -> "bg-red-500"
        "2W" -> "bg-red-300"
        "3L" -> "bg-blue-500"
        "2L" -> "bg-blue-300"
        "X" -> "bg-black"
        _ -> "bg-gray-300"
      end

    tile =
      hand
      |> Enum.filter(&(!is_nil(&1.position)))
      |> Enum.find(&(&1.position.row == row && &1.position.column == column))

    {:ok,
     socket
     |> assign(:background, background)
     |> assign(:row, row)
     |> assign(:column, column)
     |> assign(:value, value)
     |> assign(:tile, tile)}
  end
end
