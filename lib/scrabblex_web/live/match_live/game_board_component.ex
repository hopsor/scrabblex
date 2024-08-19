defmodule ScrabblexWeb.MatchLive.GameBoardComponent do
  use ScrabblexWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>Game Board</.header>
    </div>
    """
  end
end
