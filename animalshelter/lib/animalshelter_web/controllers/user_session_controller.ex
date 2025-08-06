defmodule AnimalshelterWeb.UserSessionController do
  use AnimalshelterWeb, :controller

  alias Animalshelter.Accounts
  alias AnimalshelterWeb.UserAuth

  def create(conn, %{"_action" => "confirmed"} = params) do
    create(conn, params, "Usuario confirmado correctamente.")
  end

  def create(conn, params) do
    create(conn, params, "¡Bienvenido de nuevo!")
  end

  # inicio de sesión con email y contraseña
  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # Para evitar ataques de enumeración de usuarios, no reveles si el correo está registrado.
      conn
      |> put_flash(:error, "Correo o contraseña inválidos.")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log-in")
    end
  end

  def update_password(conn, %{"user" => user_params} = params) do
    user = conn.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)
    {:ok, {_user, expired_tokens}} = Accounts.update_user_password(user, user_params)

    # desconectar todas las LiveViews existentes con sesiones antiguas
    UserAuth.disconnect_sessions(expired_tokens)

    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "¡Contraseña actualizada correctamente!")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Has cerrado sesión correctamente.")
    |> UserAuth.log_out_user()
  end
end
