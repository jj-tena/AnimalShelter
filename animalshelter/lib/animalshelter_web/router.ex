defmodule AnimalshelterWeb.Router do
  use AnimalshelterWeb, :router

  import AnimalshelterWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AnimalshelterWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug :spy
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  def spy(conn, _opts) do
    greeting = ~w(Hola Hey Buenas) |> Enum.random()
    conn = assign(conn, :greeting, greeting)
    # IO.inspect(conn)
    conn
  end

  scope "/", AnimalshelterWeb do
    pipe_through :browser

    live "/", AnimalLive.Index
    live "/animals", AnimalLive.Index
    live "/animals/:id", AnimalLive.Show

  end

  # Other scopes may use custom stacks.
  scope "/api", AnimalshelterWeb.Api do
    pipe_through :api

    get "/animals", AnimalController, :index
    get "/animals/:id", AnimalController, :show
    post "/animals", AnimalController, :create
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:animalshelter, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AnimalshelterWeb.Telemetry
      # forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AnimalshelterWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{AnimalshelterWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", AnimalshelterWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live_session :admin,
      on_mount: [
        {AnimalshelterWeb.UserAuth, :require_authenticated},
        {AnimalshelterWeb.UserAuth, :require_admin}
      ] do

      live "/admin/animals", AdminAnimalLive.Index
      live "/admin/animals/new", AdminAnimalLive.Form, :new
      live "/admin/animals/:id/edit", AdminAnimalLive.Form, :edit

    end

    post "/users/update-password", UserSessionController, :update_password
  end


  scope "/", AnimalshelterWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{AnimalshelterWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
