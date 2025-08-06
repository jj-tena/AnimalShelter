defmodule Animalshelter.Repo.Migrations.AddWinningTicketIdToAnimals do
  use Ecto.Migration

  def change do
    alter table(:animals) do
      add :winning_ticket_id, references(:tickets, on_delete: :nilify_all)
    end

    create index(:animals, [:winning_ticket_id])
  end
end
