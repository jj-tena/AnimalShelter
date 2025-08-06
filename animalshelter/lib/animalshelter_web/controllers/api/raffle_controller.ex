defmodule AnimalshelterWeb.Api.AnimalController do
  use AnimalshelterWeb, :controller

  alias Animalshelter.Admin

  def index(conn, _params) do
    animals = Admin.list_animals()
    render(conn, :index, animals: animals)
  end

  def show(conn, %{"id" => id}) do
    animal = Admin.get_animal!(id)
    render(conn, :show, animal: animal)
  end

  def create(conn, %{"animal" => animal_params}) do
    case Admin.create_animal(animal_params) do
      {:ok, animal} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/animals/#{animal}")
        |> render(:show, animal: animal)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        render(:error, changeset: changeset)
    end
  end



end
