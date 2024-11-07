defmodule ScrabblexWeb.Admin.LexiconLive.Show do
  use ScrabblexWeb, :live_view

  alias Scrabblex.Games
  alias ScrabblexWeb.Admin.LexiconLive.EntriesUploadWriter

  @impl true
  def mount(%{"id" => lexicon_id}, _, socket) do
    lexicon = Games.get_lexicon!(lexicon_id)

    {:ok,
     socket
     |> refresh_entries(lexicon)
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
     |> refresh_entries(socket.assigns.lexicon)
     |> put_flash(:info, "#{words_counter} words have been inserted in the lexicon")}
  end

  # Despite we aren't doing anything here, this is required for uploads
  def handle_event("validate", _params, socket), do: {:noreply, socket}

  def handle_event("reset-entries", _params, socket) do
    with {affected_rows, _} <- Games.clean_lexicon_entries(socket.assigns.lexicon.id) do
      {:noreply,
       socket
       |> refresh_entries(socket.assigns.lexicon)
       |> put_flash(:info, "#{affected_rows} entries have been removed")}
    else
      _ ->
        {:noreply, socket}
    end
  end

  defp refresh_entries(socket, lexicon) do
    page = Games.list_lexicon_entries(lexicon.id)
    page_assigns = Map.drop(page, [:entries, :__struct__])

    socket
    |> stream(:entries, page.entries, reset: true)
    |> assign(lexicon: lexicon, page: page_assigns)
  end
end
