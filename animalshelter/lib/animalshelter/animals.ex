defmodule Animalshelter.Animals do
  import Ecto.Query
  alias Animalshelter.Animals.Animal
  alias Animalshelter.Repo

  def subscribe(animal_id) do
    Phoenix.PubSub.subscribe(Animalshelter.PubSub, "animal:#{animal_id}")
  end

  def broadcast(animal_id, message) do
    Phoenix.PubSub.broadcast(Animalshelter.PubSub, "animal:#{animal_id}", message)
  end

  def list_animals do
    Repo.all(Animal)
  end

  def filter_animals(filter) do
    Animal
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> sort(filter["sort_by"])
    |> Repo.all()
  end

  defp with_status(query, status) when status in ~w(open close upcoming) do
    where(query, status: ^String.to_existing_atom(status))
  end

  defp with_status(query, _status) do
    query
  end

  defp search_by(query, q) when is_binary(q) and q != "" do
    where(query, [a], ilike(a.name, ^"%#{q}%"))
  end

  defp search_by(query, _q) do
    query
  end

  defp sort(query, "name_asc") do
    order_by(query, asc: :name)
  end

  defp sort(query, "name_desc") do
    order_by(query, desc: :name)
  end

  defp sort(query, "age_asc") do
    order_by(query, asc: :age)
  end

  defp sort(query, "age_desc") do
    order_by(query, desc: :age)
  end

  defp sort(query, _) do
    order_by(query, :id)
  end

  def get_animal!(id) do
    Repo.get!(Animal, id)
    |> Repo.preload([:winning_ticket])
  end

  def featured_animals(animal) do
    Animal
    |> where(status: :open)
    |> where([a], a.id != ^animal.id)
    |> order_by(desc: :age)
    |> limit(3)
    |> Repo.all()
  end

  def list_tickets(animal) do
    from(t in Animalshelter.Tickets.Ticket,
      where: t.animal_id == ^animal.id,
      order_by: [desc: t.inserted_at],
      preload: [:user]
    )
    |> Repo.all()
  end
end
