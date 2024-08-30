defmodule ScrabblexWeb.MatchLive.FormComponent do
  use ScrabblexWeb, :live_component

  alias Scrabblex.Games

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage match records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="match-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:lexicon_id]} type="select" label="Lexicon" options={@lexicon_options} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Match</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    lexicon_options =
      Scrabblex.Games.list_lexicons()
      |> Enum.map(&{"#{&1.name} (#{&1.flag})", &1.id})
      |> Enum.into(%{})

    {:ok, assign(socket, :lexicon_options, lexicon_options)}
  end

  @impl true
  def update(%{match: match} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Games.change_match(match))
     end)}
  end

  @impl true
  def handle_event("validate", %{"match" => match_params}, socket) do
    changeset = Games.change_match(socket.assigns.match, match_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"match" => match_params}, socket) do
    save_match(socket, socket.assigns.action, match_params)
  end

  defp save_match(socket, :new, match_params) do
    match_params_with_owner =
      match_params
      |> Map.put("players", [%{user_id: socket.assigns.current_user.id, owner: true}])

    case Games.create_match(match_params_with_owner) do
      {:ok, match} ->
        notify_parent({:saved, match})

        {:noreply,
         socket
         |> put_flash(:info, "Match created successfully")
         |> push_navigate(to: ~p"/matches/#{match}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
