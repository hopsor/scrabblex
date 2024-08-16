defmodule ScrabblexWeb.MatchLive.LobbyState do
  @moduledoc """
  Lobby State module is responsible of computing the state of a lobby.

  A lobby is relevant when a match hasn't started yet. In that moment users can connect and join.

  The lobby reflects who is connected and/or joined to the match.
  """
  defmodule Item do
    defstruct [:online, :joined, :user, :owner]
  end

  @doc """
  Receives a list of players and presences.

  Returns a list of Item with those users who are connected and/or joined the match.
  """
  def compute(players, presences) do
    items_joined =
      Enum.map(players, fn player ->
        online = Map.has_key?(presences, player.user_id)
        %Item{joined: true, user: player.user, online: online, owner: player.owner}
      end)

    joined_user_ids = Enum.map(players, & &1.user_id)

    items_not_joined =
      presences
      |> Enum.reject(fn {user_id, _user_data} ->
        user_id in joined_user_ids
      end)
      |> Enum.map(fn {_, user_data} ->
        %Item{joined: false, user: user_data.user, online: true}
      end)

    (items_joined ++ items_not_joined)
    |> Enum.sort(&(&1.user.name <= &2.user.name))
  end
end
