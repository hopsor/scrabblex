defmodule ScrabblexWeb.Admin.LexiconLive.Index do
  use ScrabblexWeb, :live_view

  alias Scrabblex.Games
  alias Scrabblex.Games.Lexicon

  @impl true
  def mount(_, _, socket) do
    {:ok, stream(socket, :lexicons, Games.list_lexicons())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Lexicon")
    |> assign(:lexicon, %Lexicon{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Lexicon")
    |> assign(:lexicon, Games.get_lexicon!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Lexicons")
    |> assign(:lexicon, nil)
  end

  @impl true
  def handle_info({ScrabblexWeb.Admin.LexiconLive.FormComponent, {:saved, lexicon}}, socket) do
    {:noreply, stream_insert(socket, :lexicons, lexicon)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lexicon = Games.get_lexicon!(id)
    {:ok, _} = Games.delete_lexicon(lexicon)

    {:noreply, stream_delete(socket, :lexicons, lexicon)}
  end
end
