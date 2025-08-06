defmodule AnimalshelterWeb.AdminAnimalLive.Index do
  use AnimalshelterWeb, :live_view

  alias Animalshelter.Admin

  import AnimalshelterWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listado de sorteos")
      |> stream(:animals, Admin.list_animals())
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <.header>
        <%= @page_title %>
        <:actions>
          <.link navigate={~p"/admin/animals/new"} class="button">
            Nuevo sorteo
          </.link>
        </:actions>
      </.header>
      <.table
        id="animals"
        rows={@streams.animals}
        row_click={fn {_, animal} -> JS.navigate(~p"/animals/#{animal}") end}
      >
        <:col :let={{_dom_id, animal}} label="Premio">
          <.link navigate={~p"/animals/#{animal}"}>
            <%= animal.name %>
          </.link>
        </:col>

        <:col :let={{_dom_id, animal}} label="Estado">
          <.badge status={animal.status}/>
        </:col>

        <:col :let={{_dom_id, animal}} label="Especie">
          <%= animal.specie %>
        </:col>

        <:col :let={{_dom_id, animal}} label="Raza">
          <%= animal.breed %>
        </:col>

        <:col :let={{_dom_id, animal}} label="Edad">
          <%= animal.age %>
        </:col>

        <:col :let={{_dom_id, animal}} label="Solicitud elegida">
          <%= animal.winning_ticket_id %>
        </:col>

        <:action :let={{_dom_id, animal}}>
          <.link navigate={~p"/admin/animals/#{animal}/edit"}>
            Editar
          </.link>
        </:action>

        <:action :let={{dom_id, animal}}>
          <.link phx-click={delete_and_hide(dom_id, animal)} data-confirm="¿Estás seguro?">
            Borrar
          </.link>
        </:action>

        <:action :let={{_dom_id, animal}}>
          <.link phx-click="draw-winner" phx-value-id={animal.id}>
            Obtener ganador
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    animal = Admin.get_animal!(id)
    {:ok, _} = Admin.delete_animal(animal)
    {:noreply, stream_delete(socket, :animals, animal)}
  end

  def handle_event("draw-winner", %{"id" => id}, socket) do
    animal = Admin.get_animal!(id)
    case Admin.draw_winner(animal) do
      {:ok, animal} ->
        socket =
          socket
          |> put_flash(:info, "¡Ticket ganador seleccionado!")
          |> stream_insert(:animals, animal)
        {:noreply, socket}
      {:error, error} ->
        {:noreply, put_flash(socket, :error, error)}
    end
  end

  def delete_and_hide(dom_id, animal) do
    JS.push("delete", value: %{id: animal.id})
    |> JS.hide(to: "##{dom_id}", transition: "fade-out")
  end
end
