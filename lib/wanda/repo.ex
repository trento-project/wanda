defmodule Wanda.Repo do
  use Ecto.Repo,
    otp_app: :wanda,
    adapter: Ecto.Adapters.Postgres
end
