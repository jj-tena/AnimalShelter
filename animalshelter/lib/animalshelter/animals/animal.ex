defmodule Animalshelter.Animals.Animal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "animals" do
    field :name, :string
    field :description, :string
    field :specie, :string
    field :breed, :string
    field :age, :integer
    field :status, Ecto.Enum, values: [:open, :upcoming, :close], default: :open
    field :image_path, :string, default: "/images/placeholder.jpg"
    field :disease, :string

    has_many :tickets, Animalshelter.Tickets.Ticket
    belongs_to :winning_ticket, Animalshelter.Tickets.Ticket

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(animal, attrs) do
    animal
    |> cast(attrs, [:name, :description, :specie, :breed, :age, :status, :image_path, :disease, :winning_ticket_id])
    |> validate_required([:name, :description, :specie, :breed, :age, :status])
    |> validate_length(:description, min: 10)
    |> validate_number(:age, greater_than_or_equal_to: 0)
  end
end
