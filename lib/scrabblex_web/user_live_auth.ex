defmodule ScrabblexWeb.UserLiveAuth do
  import Phoenix.Component
  # from `mix phx.gen.auth`
  alias Scrabblex.Accounts

  def on_mount(:default, _params, %{"user_token" => user_token} = _session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        Accounts.get_user_by_session_token(user_token)
      end)

    {:cont, socket}

    # if socket.assigns.current_user.confirmed_at do
    #   {:cont, socket}
    # else
    #   {:halt, redirect(socket, to: "/users/log_in")}
    # end
  end
end
