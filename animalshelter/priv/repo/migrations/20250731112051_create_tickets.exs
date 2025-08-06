defmodule Animalshelter.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :comment, :string
      add :animal_id, references(:animals, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tickets, [:animal_id])
    create index(:tickets, [:user_id])

    create unique_index(:tickets, [:animal_id, :user_id])
  end
end
