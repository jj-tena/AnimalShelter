defmodule AnimalshelterWeb.UserLive.Settings do
  use AnimalshelterWeb, :live_view

  on_mount {AnimalshelterWeb.UserAuth, :require_sudo_mode}

  alias Animalshelter.Accounts

  @impl true
  def render(assigns) do
    ~H"""
      <div class="text-center">
        <.header>
          Configuración de la cuenta
          <:subtitle>Modifica el correo electrónico, nombre de usuario y la contraseña de tu cuenta</:subtitle>
        </.header>
      </div>

      <.simple_form for={@username_form} id="username_form" phx-submit="update_username" phx-change="validate_username">
        <.input
          field={@username_form[:username]}
          type="text"
          label="Nombre de usuario"
          autocomplete="username"
          required
        />
        <.button phx-disable-with="Cambiando...">Cambiar nombre de usuario</.button>
      </.simple_form>

      <div class="divider" />

      <.simple_form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email">
        <.input
          field={@email_form[:email]}
          type="email"
          label="Email"
          autocomplete="username"
          required
        />
        <.button phx-disable-with="Cambiando...">Cambiar correo</.button>
      </.simple_form>

      <div class="divider" />

      <.simple_form
        for={@password_form}
        id="password_form"
        action={~p"/users/update-password"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <input
          name={@password_form[:email].name}
          type="hidden"
          id="hidden_user_email"
          autocomplete="username"
          value={@current_email}
        />
        <.input
          field={@password_form[:password]}
          type="password"
          label="Nueva contraseña"
          autocomplete="new-password"
          required
        />
        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirmar nueva contraseña"
          autocomplete="new-password"
        />
        <.button phx-disable-with="Guardando...">
          Guardar contraseña
        </.button>
      </.simple_form>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Correo electrónico cambiado con éxito.")

        {:error, _} ->
          put_flash(socket, :error, "El enlace para cambiar el correo no es válido o ha expirado.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)
    username_changeset = Accounts.change_user_username(user, %{}, validate_unique: false)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:username_form, to_form(username_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_username", %{"user" => user_params}, socket) do
    username_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_username(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, username_form: username_form)}
  end

  def handle_event("update_username", %{"user" => user_params}, socket) do
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_username(user, user_params) do
      %{valid?: true} = changeset ->
        {:ok, _user} = Accounts.update_user_username(user, changeset.changes)

        info = "Nombre de usuario actualizado con éxito."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :username_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_email", %{"user" => user_params}, socket) do
    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", %{"user" => user_params}, socket) do
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.update_user_email(user, user_params) do
      {:ok, _user} ->
        info = "El correo electrónico se ha actualizado correctamente."
        {:noreply, socket |> put_flash(:info, info)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :update))}
    end
  end

  def handle_event("validate_password", %{"user" => user_params}, socket) do
    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", %{"user" => user_params}, socket) do
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end
end
