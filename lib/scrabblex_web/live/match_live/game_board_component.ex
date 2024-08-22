defmodule ScrabblexWeb.MatchLive.GameBoardComponent do
  use ScrabblexWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>Game Board</.header>

      <div class="max-w-5xl mx-auto">
        <div class="flex flex-row">
          <div class="basis-8/12 p-4">
            <div id="board_wrapper" class="grid grid-cols-15 gap-1">
              <%= for {x, y, value} <- @board_layout do %>
                <.live_component
                  module={ScrabblexWeb.MatchLive.BoardSlotComponent}
                  x={x}
                  y={y}
                  value={value}
                  id={"slot_#{x}_#{y}"}
                />
              <% end %>
            </div>

            <div id="hand" class="flex flex-row justify-center gap-x-1 mt-5">
              <div
                :for={tile <- @current_player.hand}
                class="basis-1/7 bg-yellow-200 rounded-md w-14 h-14 flex flex-col-reverse"
              >
                <div class="text-xl font-bold text-center basis-5/6 "><%= tile.value %></div>
                <div class="text-xs text-right basis-1/6"><%= tile.score %></div>
              </div>
            </div>

            <div id="actions" class="mt-5 text-center">
              <.button>
                <.icon name="hero-check-circle" /> Submit word
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
    current_player = Enum.find(match.players, &(&1.user_id == current_user.id))

    {:ok,
     socket
     |> assign(:current_player, current_player)
     |> assign(:match, match)}
  end
end
