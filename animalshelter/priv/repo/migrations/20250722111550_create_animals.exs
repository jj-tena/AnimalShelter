defmodule Animalshelter.Repo.Migrations.CreateAnimals do
  use Ecto.Migration

  def change do
    create table(:animals) do
      add :name, :string
      add :description, :text
      add :specie, :string
      add :breed, :string
      add :age, :integer
      add :status, :string
      add :image_path, :string
      add :disease, :string

      timestamps(type: :utc_datetime)
    end
  end
end
