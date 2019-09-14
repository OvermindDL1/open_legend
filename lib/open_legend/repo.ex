defmodule OpenLegend.Repo do
  use Ecto.Repo,
    otp_app: :open_legend,
    adapter: Ecto.Adapters.Postgres
end
