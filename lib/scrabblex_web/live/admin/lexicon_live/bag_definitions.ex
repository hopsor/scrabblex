defmodule ScrabblexWeb.Admin.LexiconLive.BagDefinitions do
  alias Scrabblex.Games.BagDefinition
  use ScrabblexWeb, :live_view

  alias Scrabblex.Games

  @impl true
  def mount(%{"id" => lexicon_id}, _, socket) do
    lexicon = Games.get_lexicon!(lexicon_id)

    {:ok,
     socket
     |> assign(lexicon: lexicon)
     |> allow_upload(:definitions_csv, accept: ~w(.csv), max_entries: 1)}
  end

  @impl true
  def handle_event("upload", _params, socket) do
    [definitions] =
      consume_uploaded_entries(socket, :definitions_csv, fn %{path: path}, _entry ->
        {:ok,
         File.stream!(path)
         |> CSV.decode!(headers: true)
         |> Enum.map(&BagDefinition.changeset(%BagDefinition{}, &1))}
      end)

    {:ok, updated_lexicon} =
      Games.update_lexicon_definitions(socket.assigns.lexicon, %{"bag_definitions" => definitions})

    {:noreply,
     socket
     |> assign(:lexicon, updated_lexicon)
     |> put_flash(:info, "#{Enum.count(definitions)} definitions have been saved in the lexicon")}
  end

  # Despite we aren't doing anything here, this is required for uploads
  def handle_event("validate", _params, socket), do: {:noreply, socket}

  def handle_event("reset-definitions", _params, socket) do
    with {:ok, updated_lexicon} <-
           Games.update_lexicon_definitions(socket.assigns.lexicon, %{
             "bag_definitions" => nil
           }) do
      {:noreply,
       socket
       |> assign(:lexicon, updated_lexicon)
       |> put_flash(:info, "Lexicon have been updated")}
    else
      _ ->
        {:noreply, socket}
    end
  end
end
