defmodule ScrabblexWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use ScrabblexWeb, :controller` and
  `use ScrabblexWeb, :live_view`.
  """
  use ScrabblexWeb, :html

  embed_templates "layouts/*"

  attr :id, :string
  attr :current_user, :any

  def nav_account_dropdown(assigns) do
    ~H"""
    <.dropdown id={@id} user={@current_user}>
      <:link navigate={~p"/users/settings"}>Settings</:link>
      <:link :if={@current_user.admin} navigate={~p"/admin"}>Admin</:link>
      <:link href={~p"/users/log_out"} method={:delete}>Sign out</:link>
    </.dropdown>
    """
  end

  attr :id, :string
  attr :active_tab, :atom

  def nav_links(assigns) do
    ~H"""
    <div class="hidden md:block">
      <div class="ml-10 flex items-baseline space-x-4">
        <.link
          href={~p"/dashboard"}
          class={"rounded-md px-3 py-2 text-sm font-medium text-gray-300 #{if @active_tab == :dashboard, do: "bg-gray-900 text-white", else: "hover:bg-gray-700 hover:text-white"}"}
        >
          Dashboard
        </.link>
        <.link
          href={~p"/matches"}
          class={"rounded-md px-3 py-2 text-sm font-medium text-gray-300 #{if @active_tab == :match, do: "bg-gray-900 text-white", else: "hover:bg-gray-700 hover:text-white"}"}
        >
          Matches
        </.link>
      </div>
    </div>
    """
  end
end
