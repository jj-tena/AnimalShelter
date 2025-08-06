defmodule AnimalshelterWeb.UserLive.Login do
  use AnimalshelterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.header>
            <p>Iniciar sesión</p>
            <:subtitle>
              <%= if @current_scope do %>
                Necesitas iniciar sesión para realizar ciertas acciones.
              <% else %>
                ¿No tienes una cuenta? <.link
                  navigate={~p"/users/register"}
                  class="font-semibold text-brand hover:underline"
                  phx-no-format
                >Regístrate</.link> ahora para obtener una cuenta.
              <% end %>
            </:subtitle>
          </.header>
        </div>

        <.simple_form
          :let={f}
          for={@form}
          id="login_form_password"
          action={~p"/users/log-in"}
          phx-submit="submit_password"
          phx-trigger-action={@trigger_submit}
          as={:user}
        >
          <.input
            field={f[:email]}
            type="email"
            label="Email"
            required
          />
          <.input
            field={f[:password]}
            type="password"
            label="Contraseña"
            required
          />
          <.input
            field={f[:remember_me]}
            type="checkbox"
            label="Recuérdame"
          />
          <.button type="submit">Iniciar sesión</.button>
        </.simple_form>
      </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

end
