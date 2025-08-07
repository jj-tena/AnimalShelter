defmodule Animalshelter.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :full_name, :string
      add :phone_number, :string
      add :description, :text
      add :city, :string
    end
  end
end
