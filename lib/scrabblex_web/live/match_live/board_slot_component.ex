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
        @dropzone_class
      ]}
      data-row={@row}
      data-column={@column}
    >
      <div :if={@booster} class="absolute text-white font-bold">
        <%= @booster %>
      </div>

      <TileComponent.tile
        :if={@tile}
        tile={@tile}
        draggable_class={@draggable_class}
        friendly_id={@friendly_id}
        played={@played}
      />
    </div>
    """
  end

  @impl true
  def update(
        %{
          booster: booster,
          row: row,
          column: column,
          tile: tile,
          played: played,
          friendly_id: friendly_id
        },
        socket
      ) do
    background =
      case booster do
        "3W" -> "bg-red-500"
        "2W" -> "bg-red-300"
        "3L" -> "bg-blue-500"
        "2L" -> "bg-blue-300"
        "X" -> "bg-black"
        _ -> "bg-gray-300"
      end

    {dropzone_class, draggable_class} = if played, do: {"", ""}, else: {"dropzone", "draggable"}

    {:ok,
     socket
     |> assign(:background, background)
     |> assign(:row, row)
     |> assign(:column, column)
     |> assign(:booster, booster)
     |> assign(:tile, tile)
     |> assign(:dropzone_class, dropzone_class)
     |> assign(:draggable_class, draggable_class)
     |> assign(:friendly_id, friendly_id)
     |> assign(:played, played)}
  end
end
