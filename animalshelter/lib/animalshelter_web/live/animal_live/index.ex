defmodule AnimalshelterWeb.AnimalLive.Index do
  use AnimalshelterWeb, :live_view

  alias Animalshelter.Animals
  alias AnimalshelterWeb.CustomComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    animals = Animals.filter_animals(params)

    socket =
      socket
      |> stream(:animals, [], reset: true)
      |> stream(:animals, animals)
      |> assign(:form, to_form(params))

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="animal-index">
      <CustomComponents.banner>
        <.icon name="hero-sparkles-solid"/> AnimalShelter
        <:details>
          Adopta un animal y dale una nueva vida.
        </:details>
      </CustomComponents.banner>

      <div class="animals" id="animals" phx-update="stream">
        <.animal_card :for={{dom_id, animal} <- @streams.animals} animal={animal} id={dom_id}/>
      </div>
    </div>
    """
  end

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} id="filter_form" phx-change="filter">
      <.input
        field={@form[:q]}
        placeholder="Buscar..."
        autocomplete="off"
        phx-debounce="500"
      />

      <.input
        type="select"
        field={@form[:status]}
        prompt="Estado"
        options={[
          {"Próximo", :upcoming},
          {"Abierto", :open},
          {"Cerrado", :close}
        ]}
      />

      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Ordenar por"
        options={[
          {"Edad", "age"}
        ]}
      />

      <.link patch={~p"/animals"}>
        Restablecer
      </.link>
    </.form>
    """
  end

  def handle_event("filter", params, socket) do
    params =
      params
      |> Map.take(~w(q status sort_by))
      |> Map.reject(fn {_, v} -> v == "" end)

    socket = push_patch(socket, to: ~p"/animals?#{params}")

    {:noreply, socket}
  end

  attr :animal, Animalshelter.Animals.Animal, required: true
  attr :id, :string, required: true
  def animal_card(assigns) do
    ~H"""
    <.link navigate={~p"/animals/#{@animal}"} id={@id}>
      <div class="card">
        <div class="specie-breed">
          <%= @animal.specie %> - <%= @animal.breed %>
        </div>
        <img src={@animal.image_path} />
        <h2><%= @animal.name %></h2>
        <div class="details">

          <CustomComponents.badge status={@animal.status}/>
        </div>
      </div>
    </.link>
    """
  end
end
