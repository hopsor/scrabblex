defmodule ScrabblexWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :scrabblex,
    pubsub_server: Scrabblex.PubSub

  alias Scrabblex.Accounts

  def init(_opts) do
    {:ok, %{}}
  end

  def fetch(_topic, presences) do
    users =
      presences
      |> Map.keys()
      |> Accounts.get_users()
      |> Enum.map(&{&1.id, &1})
      |> Enum.into(%{})

    for {key, %{metas: [meta | metas]}} <- presences, into: %{} do
      user_id = String.to_integer(key)

      {key, %{metas: [meta | metas], id: user_id, user: users[user_id]}}
    end
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, presence} <- joins do
      user_data = %{id: user_id, user: presence.user, metas: Map.fetch!(presences, user_id)}
      msg = {__MODULE__, {:join, user_data}}
      Phoenix.PubSub.local_broadcast(Scrabblex.PubSub, "proxy:#{topic}", msg)
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      user_data = %{id: user_id, user: presence.user, metas: metas}
      msg = {__MODULE__, {:leave, user_data}}
      Phoenix.PubSub.local_broadcast(Scrabblex.PubSub, "proxy:#{topic}", msg)
    end

    {:ok, state}
  end

  def list_online_users(topic),
    do: list(topic) |> Enum.map(fn {_id, presence} -> presence end)

  def track_user(topic, id, params), do: track(self(), topic, id, params)

  def subscribe(topic),
    do: Phoenix.PubSub.subscribe(Scrabblex.PubSub, "proxy:#{topic}")
end
