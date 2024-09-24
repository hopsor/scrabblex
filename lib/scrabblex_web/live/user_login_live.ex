defmodule ScrabblexWeb.UserLoginLive do
  use ScrabblexWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-10">
      <div class="mx-auto max-w-lg rounded-xl bg-white p-10">
        <h1 class="text-3xl font-bold text-center">Log in to account</h1>

        <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Password" required />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
            <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
              Forgot your password?
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with="Logging in..." class="w-full">
              Log in <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>

        <div class="relative mt-6">
          <div class="absolute flex items-center inset-0">
            <div class="w-full border-t border-gray-200"></div>
          </div>
          <div class="flex relative justify-center leading-6">
            <span class="px-4 bg-white">or continue with</span>
          </div>
        </div>

        <.button class="w-full mt-6">
          <.link href={~p"/auth/github"} class="inline-flex items-baseline">
            <img src={~p"/images/github-mark-white.svg"} class="w-6 mr-2 self-center" />
            <span>Login with Github</span>
          </.link>
        </.button>
      </div>

      <div class="text-center mt-10 text-sm">
        Don't have an account?
        <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
          Sign up
        </.link>
        for an account now.
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
