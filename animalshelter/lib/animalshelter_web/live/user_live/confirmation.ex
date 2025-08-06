defmodule AnimalshelterWeb.UserLive.Confirmation do
  use AnimalshelterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>Bienvenido/a {@user.username}</.header>
        </div>

        <.simple_form
          :if={!@user.confirmed_at}
          for={@form}
          id="confirmation_form"
          phx-mounted={JS.focus_first()}
          phx-submit="submit"
          action={~p"/users/log-in?_action=confirmed"}
          phx-trigger-action={@trigger_submit}
        >
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <.button
            name={@form[:remember_me].name}
            value="true"
            phx-disable-with="Confirmando..."
            class="btn btn-primary w-full"
          >
            Confirmar y mantener sesión iniciada
          </.button>
          <.button phx-disable-with="Confirmando..." class="btn btn-primary btn-soft w-full mt-2">
            Confirmar e iniciar sesión solo esta vez
          </.button>
        </.simple_form>

        <.simple_form
          :if={@user.confirmed_at}
          for={@form}
          id="login_form"
          phx-submit="submit"
          phx-mounted={JS.focus_first()}
          action={~p"/users/log-in"}
          phx-trigger-action={@trigger_submit}
        >
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <%= if @current_scope do %>
            <.button phx-disable-with="Iniciando sesión..." class="btn btn-primary w-full">
              Iniciar sesión
            </.button>
          <% else %>
            <.button
              name={@form[:remember_me].name}
              value="true"
              phx-disable-with="Iniciando sesión..."
              class="btn btn-primary w-full"
            >
              Mantenerme conectado/a en este dispositivo
            </.button>
            <.button phx-disable-with="Iniciando sesión..." class="btn btn-primary btn-soft w-full mt-2">
              Iniciar sesión solo esta vez
            </.button>
          <% end %>
        </.simple_form>

        <p :if={!@user.confirmed_at} class="alert alert-outline mt-8">
          Consejo: Si prefieres usar contraseña, puedes activarla en la configuración de usuario.
        </p>
      </div>
    """
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "user"), trigger_submit: true)}
  end
end
