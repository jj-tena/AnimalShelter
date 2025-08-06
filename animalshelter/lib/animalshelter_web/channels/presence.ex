defmodule AnimalshelterWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """

  use Phoenix.Presence,
    otp_app: :animalshelter,
    pubsub_server: Animalshelter.PubSub

  def track_user(id, user) do
    {:ok, _} = track(self(), topic(id), user.username, %{
          online_at: System.system_time(:second)
        })
  end

  def subscribe(id) do
    Phoenix.PubSub.subscribe(Animalshelter.PubSub, "updates:" <> topic(id))
  end

  def list_users(id) do
    list(topic(id))
      |> Enum.map(fn {email, %{metas: metas}} -> %{id: email, metas: metas} end)
  end

  def topic(id) do
    "animal_watchers:#{id}"
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {email, _presences} <- joins do
      presence = %{id: email, metas: Map.fetch!(presences, email)}
      msg = {:user_joined, presence}
      Phoenix.PubSub.local_broadcast(Animalshelter.PubSub, "updates:" <> topic, msg)
    end

    for {email, _presences} <- leaves do
      metas =
        case Map.fetch(presences, email) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end
      presence = %{id: email, metas: metas}
      msg = {:user_left, presence}
      Phoenix.PubSub.local_broadcast(Animalshelter.PubSub, "updates:" <> topic, msg)
    end

    {:ok, state}
  end
end
