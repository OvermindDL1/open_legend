use Mix.Config

# Configure your database
config :open_legend, OpenLegend.Repo,
  username: "postgres",
  password: "postgres",
  database: "open_legend_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :open_legend, OpenLegendWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Finally import the config/secrets.exs which loads secrets
# and configuration from environment variables.
import_config "secrets.exs"
