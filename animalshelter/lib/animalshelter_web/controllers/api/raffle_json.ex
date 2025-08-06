defmodule AnimalshelterWeb.Api.AnimalJSON do

  def index(%{animals: animals}) do
    %{
      animals:
        for(
          animal <- animals,
          do: data(animal)
        )
    }
  end

  def show(%{animal: animal}) do
    %{
      animal: data(animal)
    }
  end

  defp data(animal) do
    %{
      id: animal.id,
      name: animal.name,
      description: animal.description,
      status: animal.status,
      a: animal.age
    }
  end

  def error(%{changeset: changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    %{errors: errors}
  end

end
