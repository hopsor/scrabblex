defmodule ScrabblexWeb.MatchLive.Index do
  use ScrabblexWeb, :live_view

  alias Scrabblex.Games
  alias Scrabblex.Games.Match

  @impl true
  def mount(_params, _session, socket) do
    lexicon_options =
      Games.list_lexicons(enabled: true)
      |> Enum.map(&{"#{&1.flag} #{&1.name}", &1.id})
      |> Enum.into(%{})

    {:ok,
     socket
     |> stream(:matches, [])
     |> assign(:lexicon_options, lexicon_options)
     |> assign(:search_form, to_form(%{"lexicon_id" => nil}))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Match")
    |> assign(:match, Games.get_match!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Match")
    |> assign(:match, %Match{})
  end

  defp apply_action(socket, :index, params) do
    list_opts =
      params
      |> Enum.map(fn {key, value} ->
        {String.to_existing_atom(key), value}
      end)

    matches = Games.list_matches(socket.assigns.current_user, list_opts)

    socket
    |> assign(:page_title, "Open matches")
    |> assign(:match, nil)
    |> stream(:matches, matches, reset: true)
  end

  @impl true
  def handle_info({ScrabblexWeb.MatchLive.FormComponent, {:saved, match}}, socket) do
    {:noreply, stream_insert(socket, :matches, match)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    url_params =
      params
      |> Map.take(~w(lexicon_id))
      |> Map.reject(fn {_k, v} -> v == "" end)

    {:noreply, push_patch(socket, to: ~p"/matches?#{url_params}")}
  end
end
