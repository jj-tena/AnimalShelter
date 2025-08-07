defmodule Animalshelter.Admin do
  import Ecto.Query
  alias Animalshelter.Animals.Animal
  alias Animalshelter.Animals
  alias Animalshelter.Repo

  def list_animals do
    Animal
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create_animal(attrs \\ %{}) do
    %Animal{}
    |> Animal.changeset(attrs)
    |> Repo.insert()
  end

  def change_animal(%Animal{} = animal, attrs \\ %{}) do
    Animal.changeset(animal, attrs)
  end

  def get_animal!(id) do
    Repo.get!(Animal, id)
    |> Repo.preload(tickets: [:user, :animal])
  end

  def update_animal(%Animal{} = animal, attrs) do
    animal
    |> Animal.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, animal} ->
        animal = Repo.preload(animal, [:winning_ticket])
        Animals.broadcast(animal.id, {:animal_updated, animal})
        {:ok, animal}

      {:error, _} = error ->
        error
    end
  end

  def delete_animal(%Animal{} = animal) do
    Repo.delete(animal)
  end

  def draw_winner(%Animal{status: :close} = animal) do
    animal = Repo.preload(animal, :tickets)

    case animal.tickets do
      [] ->
        {:error, "No hay solicitudes entre las que elegir un adoptante"}
      tickets ->
        winner = Enum.random(tickets)
        {:ok, _animal} = update_animal(animal, %{
          winning_ticket_id: winner.id
        })
    end
  end

  def draw_winner(%Animal{}) do
    {:error, "Las presentación de solicitudes para el animal debe estar cerrada para elegir un adoptante"}
  end

end
