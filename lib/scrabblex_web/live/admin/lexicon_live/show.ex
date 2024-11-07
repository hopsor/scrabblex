defmodule ScrabblexWeb.Admin.LexiconLive.Show do
  use ScrabblexWeb, :live_view

  alias Scrabblex.Games
  alias ScrabblexWeb.Admin.LexiconLive.EntriesUploadWriter

  @impl true
  def mount(%{"id" => lexicon_id}, _, socket) do
    lexicon = Games.get_lexicon!(lexicon_id)

    {:ok,
     socket
     |> assign(
       lexicon: lexicon,
       target_page: 1,
       query: "",
       search_form: to_form(%{"q" => ""})
     )
     |> refresh_entries()
     |> allow_upload(:entries_file,
       accept: ~w(.txt),
       writer: fn _name, _entry, _socket -> {EntriesUploadWriter, [lexicon_id: lexicon.id]} end
     )}
  end

  @impl true
  def handle_event("upload", _params, socket) do
    [words_counter] =
      consume_uploaded_entries(socket, :entries_file, fn %{words_counter: words_counter},
                                                         _entry ->
        {:ok, words_counter}
      end)

    {:noreply,
     socket
     |> refresh_entries()
     |> put_flash(:info, "#{words_counter} words have been inserted in the lexicon")}
  end

  # Despite we aren't doing anything here, this is required for uploads
  def handle_event("validate", _params, socket), do: {:noreply, socket}

  def handle_event("reset-entries", _params, socket) do
    with {affected_rows, _} <- Games.clean_lexicon_entries(socket.assigns.lexicon.id) do
      {:noreply,
       socket
       |> refresh_entries()
       |> put_flash(:info, "#{affected_rows} entries have been removed")}
    else
      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("search", %{"q" => query}, socket) do
    {:noreply, assign(socket, query: query, target_page: 1) |> refresh_entries()}
  end

  def handle_event("go_to_page", %{"page" => page_number}, socket) do
    {:noreply, assign(socket, target_page: String.to_integer(page_number)) |> refresh_entries()}
  end

  defp refresh_entries(socket) do
    paginated =
      Games.list_lexicon_entries(
        socket.assigns.lexicon.id,
        socket.assigns.target_page,
        socket.assigns.query
      )

    page_assigns = Map.drop(paginated, [:entries, :__struct__])

    socket
    |> stream(:entries, paginated.entries, reset: true)
    |> assign(page_data: page_assigns)
  end
end
