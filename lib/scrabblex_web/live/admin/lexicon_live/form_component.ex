defmodule ScrabblexWeb.Admin.LexiconLive.FormComponent do
  use ScrabblexWeb, :live_component

  alias Scrabblex.Games

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="lexicon-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:language]} type="text" label="Language" />
        <.input field={@form[:flag]} type="text" label="Flag" />
        <.input field={@form[:enabled]} type="checkbox" label="Enabled" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Lexicon</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{lexicon: lexicon} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Games.change_lexicon(lexicon))
     end)}
  end

  @impl true
  def handle_event("validate", %{"lexicon" => lexicon_params}, socket) do
    changeset = Games.change_lexicon(socket.assigns.lexicon, lexicon_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"lexicon" => lexicon_params}, socket) do
    save_lexicon(socket, socket.assigns.action, lexicon_params)
  end

  defp save_lexicon(socket, :new, params) do
    case Games.create_lexicon(params) do
      {:ok, lexicon} ->
        notify_parent({:saved, lexicon})

        {:noreply,
         socket
         |> put_flash(:info, "Lexicon created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_lexicon(socket, :edit, params) do
    case Games.update_lexicon(socket.assigns.lexicon, params) do
      {:ok, lexicon} ->
        notify_parent({:saved, lexicon})

        {:noreply,
         socket
         |> put_flash(:info, "Lexicon updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
