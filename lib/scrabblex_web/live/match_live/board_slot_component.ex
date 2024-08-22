defmodule ScrabblexWeb.MatchLive.BoardSlotComponent do
  use ScrabblexWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class={[
      "aspect-square h-auto flex items-center justify-center rounded-lg relative",
      @background,
      "dropzone"
    ]}>
      <div :if={@value} class="absolute text-white font-bold">
        <%= @value %>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{value: value}, socket) do
    background =
      case value do
        "3W" -> "bg-red-500"
        "2W" -> "bg-red-300"
        "3L" -> "bg-blue-500"
        "2L" -> "bg-blue-300"
        "X" -> "bg-black"
        _ -> "bg-gray-300"
      end

    {:ok,
     socket
     |> assign(:background, background)
     |> assign(:value, value)}
  end
end
