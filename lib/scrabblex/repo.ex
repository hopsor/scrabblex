defmodule Scrabblex.Repo do
  use Ecto.Repo,
    otp_app: :scrabblex,
    adapter: Ecto.Adapters.Postgres
end
