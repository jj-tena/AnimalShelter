defmodule Animalshelter.Tickets.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tickets" do
    field :comment, :string

    belongs_to :animal, Animalshelter.Animals.Animal
    belongs_to :user, Animalshelter.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:comment])
    |> validate_length(:comment, max: 100)
    |> assoc_constraint(:animal)
    |> assoc_constraint(:user)
  end
end
