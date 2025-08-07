defmodule AnimalshelterWeb.AdminAnimalLive.Index do
  use AnimalshelterWeb, :live_view

  alias Animalshelter.Admin
  alias Animalshelter.Repo

  import AnimalshelterWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listado de animales")
      |> assign(:selected_animal, nil)
      |> assign(:tickets, [])
      |> assign(:show_modal, false)
      |> assign(:modal_error, nil)
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
            Nuevo animal
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
          <.link phx-click="open-modal" phx-value-id={animal.id}>
            Seleccionar adoptante
          </.link>
        </:action>
      </.table>
    </div>

    <%= if @show_modal do %>
      <.modal id="select-winner-modal" show style="max-width: 90vw; width: auto;">
        <h2 class="mb-4">Seleccionar adoptante para <strong><%= @selected_animal.name %> </strong></h2>
        <%= if @modal_error do %>
          <p class="text-red-600 font-bold"><%= @modal_error %></p>
        <% else %>
          <table class="table-auto w-full">
            <thead>
              <tr class="bg-gray-100">
                <th class="px-4 py-2 text-left">Nombre Completo</th>
                <th class="px-4 py-2 text-left">Teléfono</th>
                <th class="px-4 py-2 text-left">Ciudad</th>
                <th class="px-4 py-2 text-left">Descripción</th>
                <th class="px-4 py-2 text-left">Acción</th>
              </tr>
            </thead>
            <tbody>
              <%= for ticket <- @tickets do %>
                <tr class="border-t">
                  <td class="px-4 py-2"><%= ticket.user.full_name || "-" %></td>
                  <td class="px-4 py-2"><%= ticket.user.phone_number || "-" %></td>
                  <td class="px-4 py-2"><%= ticket.user.city || "-" %></td>
                  <td class="px-4 py-2"><%= ticket.user.description || "-" %></td>
                  <td class="px-4 py-2">
                    <.button phx-click="select-winner" phx-value-ticket-id={ticket.id}>
                      Seleccionar
                    </.button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        <% end %>

        <div class="mt-4">
          <.button phx-click="close-modal">Cancelar</.button>
        </div>
      </.modal>
    <% end %>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    animal = Admin.get_animal!(id)
    {:ok, _} = Admin.delete_animal(animal)
    {:noreply, stream_delete(socket, :animals, animal)}
  end

  def handle_event("open-modal", %{"id" => id}, socket) do
    animal = Admin.get_animal!(id) |> Repo.preload(tickets: [:user])

    cond do
      animal.status != :close ->
        {:noreply,
         socket
         |> assign(:selected_animal, animal)
         |> assign(:tickets, [])
         |> assign(:show_modal, true)
         |> assign(:modal_error, "El estado del animal no está cerrado.")}

      animal.status == :close and animal.tickets == [] ->
        {:noreply,
         socket
         |> assign(:selected_animal, animal)
         |> assign(:tickets, [])
         |> assign(:show_modal, true)
         |> assign(:modal_error, "El animal está cerrado pero no tiene solicitudes.")}

      true ->
        {:noreply,
         socket
         |> assign(:selected_animal, animal)
         |> assign(:tickets, animal.tickets)
         |> assign(:show_modal, true)
         |> assign(:modal_error, nil)}
    end
  end

  def handle_event("select-winner", %{"ticket-id" => ticket_id}, socket) do
    animal = socket.assigns.selected_animal

    case Admin.update_animal(animal, %{winning_ticket_id: ticket_id}) do
      {:ok, updated_animal} ->
        updated_animal = Repo.preload(updated_animal, :winning_ticket)

        {:noreply,
         socket
         |> put_flash(:info, "Adoptante seleccionado exitosamente.")
         |> stream_insert(:animals, updated_animal)
         |> assign(:show_modal, false)
         |> assign(:selected_animal, nil)
         |> assign(:tickets, [])
         |> assign(:modal_error, nil)
        }

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "No se pudo seleccionar el adoptante.")}
    end
  end

  def handle_event("close-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_modal, false)
     |> assign(:selected_animal, nil)
     |> assign(:tickets, [])
     |> assign(:modal_error, nil)}
  end

  def delete_and_hide(dom_id, animal) do
    JS.push("delete", value: %{id: animal.id})
    |> JS.hide(to: "##{dom_id}", transition: "fade-out")
  end
end
