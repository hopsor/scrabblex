defmodule ScrabblexWeb.MatchLive.WildcardEditorComponent do
  use ScrabblexWeb, :live_component

  alias Scrabblex.Games
  alias Scrabblex.Games.{Bag, Lexicon, Match}

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Choose a letter
        <:subtitle>Click on the desired value</:subtitle>
      </.header>

      <div id="choices" class="grid grid-cols-6 gap-4 mt-5">
        <div
          :for={choice <- @choices}
          phx-click="commit_wildcard_value"
          phx-value-choice={choice}
          phx-target={@myself}
          class="cursor-pointer bg-yellow-200 rounded-md aspect-square w-full h-auto relative shadow-inner"
        >
          <div class="text-md font-bold text-center absolute inset-0 h-full w-full flex items-center justify-center select-none">
            <%= choice %>
          </div>

          <div class="text-xs text-right absolute right-0.5 top-0.5">0</div>
        </div>
      </div>
    </div>
    """
  end

  def update(
        %{
          match: %Match{lexicon: %Lexicon{name: lexicon_name}} = match,
          wildcard: wildcard,
          current_player: current_player
        },
        socket
      ) do
    choices =
      Bag.distribution(lexicon_name)
      |> Map.keys()
      |> Enum.sort()

    {:ok,
     socket
     |> assign(:choices, choices)
     |> assign(:wildcard, wildcard)
     |> assign(:current_player, current_player)
     |> assign(:match, match)}
  end

  def handle_event("commit_wildcard_value", %{"choice" => choice}, socket) do
    current_player = socket.assigns.current_player

    hand_changesets =
      current_player.hand
      |> Enum.map(fn tile ->
        if tile.id == socket.assigns.wildcard.id do
          Games.change_tile(tile, %{value: choice})
        else
          Games.change_tile(tile)
        end
      end)

    with {:ok, player} <- Games.update_player_hand(current_player, hand_changesets) do
      send(self(), {:updated_player, player})

      {:noreply,
       socket
       |> put_flash!(:info, "Wildcard updated to #{choice}")
       |> push_patch(to: ~p"/m/#{socket.assigns.match}")}
    else
      {:error, :stale_player} ->
        {:noreply,
         socket
         |> put_flash(:error, "Your data was stale. Reloading the page to fetch fresh data")
         |> push_navigate(to: ~p"/m/#{socket.assigns.match}")}
    end
  end
end
