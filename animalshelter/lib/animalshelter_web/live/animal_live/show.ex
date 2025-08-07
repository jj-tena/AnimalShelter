defmodule AnimalshelterWeb.AnimalLive.Show do
  use AnimalshelterWeb, :live_view

  alias Animalshelter.Animals
  alias AnimalshelterWeb.CustomComponents
  alias Animalshelter.Tickets
  alias Animalshelter.Tickets.Ticket
  alias AnimalshelterWeb.Presence

  on_mount {AnimalshelterWeb.UserAuth, :mount_current_scope}

  def mount(_params, _session, socket) do
    changeset = Tickets.change_ticket(%Ticket{})
    socket = assign(socket, :form, to_form(changeset))
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    user = socket.assigns.current_scope && socket.assigns.current_scope.user

    if connected?(socket) do
      Animals.subscribe(id)

      if user do
        Presence.track_user(id, user)
        Presence.subscribe(id)
      end
    end

    presences = Presence.list_users(id)
    animal = Animals.get_animal!(id) |> Animalshelter.Repo.preload(winning_ticket: [:user])
    tickets = Animals.list_tickets(animal)

    # Verificar si el usuario ya tiene ticket para este animal
    has_ticket =
      if user do
        Enum.any?(tickets, fn t -> t.user_id == user.id end)
      else
        false
      end

    socket =
      socket
      |> assign(:animal, animal)
      |> stream(:tickets, tickets)
      |> stream(:presences, presences)
      |> assign(:ticket_count, Enum.count(tickets))
      |> assign(:has_ticket, has_ticket)
      |> assign(:page_title, animal.name)
      |> assign_async(:featured_animals, fn ->
        {:ok, %{featured_animals: Animals.featured_animals(animal)}}
      end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="animal-show">
      <CustomComponents.banner :if={@animal.winning_ticket}>
        <.icon name="hero-sparkles-solid"/>
        El usuario <%= @animal.winning_ticket.user && @animal.winning_ticket.user.username %> ha sido seleccionado para adoptar a <%= @animal.name %>
        <:details>
          {@animal.winning_ticket.comment}
        </:details>
      </CustomComponents.banner>

      <div class="animal">
        <img src={@animal.image_path} />
        <section>
          <CustomComponents.badge status={@animal.status} />
          <header>
            <div>
              <h2><%= @animal.name %></h2>
            </div>
            <div class="name">
              <%= @animal.specie %>
            </div>
            <div class="name">
              <%= @animal.breed %>
            </div>
            <div class="name">
              <%= @animal.age %> años
            </div>
          </header>
          <div class="totals">
            <%= @ticket_count %> Solicitudes de adopción
          </div>
          <div class="description">
            <%= @animal.description %>
          </div>
        </section>
      </div>

      <div class="activity">
        <div class="left">
          <div :if={@animal.status == :open}>
            <%= if @current_scope && @current_scope.user do %>
              <%= if !@has_ticket do %>
                <.form for={@form} id="ticket-form" phx-change="validate" phx-submit="save">
                  <.input type="textarea" field={@form[:comment]} placeholder="Comenta..." autofocus/>
                  <.button>
                    Enviar solicitud
                  </.button>
                </.form>
              <% else %>
                <div class="failed">Ya has presentado una solicitud para este animal.</div>
              <% end %>
            <% else %>
              <.link href={~p"/users/log-in"} class="button">
                Inicia sesión para enviar tu solicitud de adopción
              </.link>
            <% end %>
          </div>
          <div id="tickets" phx-update="stream">
            <.ticket :for={{dom_id, ticket} <- @streams.tickets}
              ticket={ticket}
              id={dom_id}
            />
          </div>
        </div>

        <div class="right">
          <.featured_animals animals={@featured_animals}/>
          <.animal_watchers :if={@current_scope && @current_scope.user} presences={@streams.presences}/>
        </div>
      </div>
    </div>
    """
  end

  def animal_watchers(assigns) do
    ~H"""
    <section>
      <h4>Espectadores</h4>
      <ul class="presences" id="animal-watchers" phx-update="stream">
        <li :for={{dom_id, %{id: email, metas: metas}} <- @presences} id={dom_id}>
          <.icon name="hero-user-circle-solid" class="w-5 h-5"/>
          <%= email %> (<%= length(metas) %>)
        </li>
      </ul>
    </section>
    """
  end

  def featured_animals(assigns) do
    ~H"""
    <section>
      <h4>Otros animales</h4>
      <.async_result :let={result} assign={@animals}>
        <:loading>
          <div class="spinner"> </div>
        </:loading>
        <:failed :let={{:error, reason}}>
          <div class="failed">
            Error: <%= reason %>
          </div>
        </:failed>
        <ul class="animals">
          <li :for={animal <- result}>
            <.link navigate={~p"/animals/#{animal}"}>
              <img src={animal.image_path} /> <%= animal.name %>
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end

  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    changeset = Tickets.change_ticket(%Ticket{}, ticket_params)
    socket = assign(socket, :form, to_form(changeset, action: :validate))
    {:noreply, socket}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do
    %{animal: animal, current_scope: %{user: user}} = socket.assigns
    case Tickets.create_ticket(animal, user, ticket_params) do
      {:ok, ticket} ->
        changeset = Tickets.change_ticket(%Ticket{})
        socket =
          socket
          |> assign(:form, to_form(changeset))
          |> stream_insert(:tickets, ticket, at: 0)
          |> update(:ticket_count, &(&1 + 1))
          |> assign(:has_ticket, true)
        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end

  def handle_info({:ticket_created, ticket}, socket) do
    socket =
      socket
      |> stream_insert(:tickets, ticket, at: 0)
      |> update(:ticket_count, &(&1 + 1))
    {:noreply, socket}
  end

  def handle_info({:animal_updated, animal}, socket) do
    {:noreply, assign(socket, :animal, animal)}
  end

  def handle_info({:user_joined, presence}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({:user_left, presence}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end

  attr :id, :string, required: true
  attr :ticket, Ticket, required: true
  def ticket(assigns) do
    ~H"""
    <div class="ticket" id={@id}>
      <span class="timeline"></span>
      <section>
        <div>
          <span class="username">
            {@ticket.user.username}
          </span>
          dejó un comentario
          <blockquote>
            {@ticket.comment}
          </blockquote>
        </div>
      </section>
    </div>
    """
  end
end
