defmodule ScrabblexWeb.MatchLive.PlayLog do
  use Phoenix.Component

  def play(assigns) do
    ~H"""
    <div class="play">
      <strong><%= @play.player.user.name %></strong>
      earned <strong><%= @play.score %> points</strong>
      by composing words:<br /><%= Enum.map(@play.words, & &1.value) |> Enum.join(", ") %>
    </div>
    """
  end

  def skip(assigns) do
    ~H"""
    <div class="skip"><strong><%= @play.player.user.name %></strong> skipped turn</div>
    """
  end

  def exchange(assigns) do
    ~H"""
    <div class="exchange"><strong><%= @play.player.user.name %></strong> exchanged tiles</div>
    """
  end
end
