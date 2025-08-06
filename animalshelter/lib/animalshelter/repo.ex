defmodule Animalshelter.Repo do
  use Ecto.Repo,
    otp_app: :animalshelter,
    adapter: Ecto.Adapters.Postgres
end
