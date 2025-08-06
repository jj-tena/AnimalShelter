defmodule Animalshelter.TicketsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Animalshelter.Tickets` context.
  """

  @doc """
  Generate a ticket.
  """
  def ticket_fixture(attrs \\ %{}) do
    {:ok, ticket} =
      attrs
      |> Enum.into(%{
        comment: "some comment",
        name: 42
      })
      |> Animalshelter.Tickets.create_ticket()

    ticket
  end
end
