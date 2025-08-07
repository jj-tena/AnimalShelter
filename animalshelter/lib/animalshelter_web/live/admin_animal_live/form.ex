defmodule AnimalshelterWeb.AdminAnimalLive.Form do
  use AnimalshelterWeb, :live_view
  alias Animalshelter.Admin
  alias Animalshelter.Animals.Animal

  def mount(params, _session, socket) do
    socket =
      socket
      |> apply_action(socket.assigns.live_action, params)

    {:ok, socket}
  end

  defp apply_action(socket, :new, _params) do
    animal = %Animal{}

    changeset = Admin.change_animal(animal)

    socket
      |> assign(:page_title, "Nuevo animal")
      |> assign(:form, to_form(changeset))
      |> assign(:animal, animal)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    animal = Admin.get_animal!(id)

    changeset = Admin.change_animal(animal)

    socket
      |> assign(:page_title, "Editar animal")
      |> assign(:form, to_form(changeset))
      |> assign(:animal, animal)
  end

  def render(assigns) do
    ~H"""
    <.header>
      <%= @page_title %>
    </.header>

    <.simple_form for={@form} id="animal-form" phx-submit="save" phx-change="validate">
      <.input field={@form[:name]} label="Nombre" />
      <.input field={@form[:description]} type="textarea" label="Descripción" phx-debounce="2000" />
      <.input field={@form[:specie]} label="Especie" />
      <.input field={@form[:breed]} label="Raza" />
      <.input field={@form[:age]} type="number" label="Edad (en años)" />

      <.input
        field={@form[:status]}
        type="select"
        label="Estado"
        prompt="Elige un estado"
        options={[
          {"Próximo", :upcoming},
          {"Abierto", :open},
          {"Cerrado", :close}
        ]}
      />

      <.input field={@form[:disease]} label="Enfermedades conocidas" />
      <.input field={@form[:image_path]} label="URL de la imagen" />

      <:actions>
        <.button>Guardar animal</.button>
      </:actions>
    </.simple_form>

    <.back navigate={~p"/admin/animals"}>
      Volver
    </.back>
    """
  end

  def handle_event("save", %{"animal" => animal_params}, socket) do
    save_animal(socket, socket.assigns.live_action, animal_params)
  end

  def handle_event("validate", %{"animal" => animal_params}, socket) do
    changeset = Admin.change_animal(socket.assigns.animal, animal_params)
    socket = assign(socket, :form, to_form(changeset, action: :validate))
    {:noreply, socket}
  end

  defp save_animal(socket, :new, animal_params) do
    case Admin.create_animal(animal_params) do
      {:ok, _animal} ->
        socket =
          socket
          |> put_flash(:info, "Animal creado correctamente!")
          |> push_navigate(to: ~p"/admin/animals")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end

  defp save_animal(socket, :edit, animal_params) do
    case Admin.update_animal(socket.assigns.animal, animal_params) do
      {:ok, _animal} ->
        socket =
          socket
          |> put_flash(:info, "Animal editado correctamente!")
          |> push_navigate(to: ~p"/admin/animals")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end

end
