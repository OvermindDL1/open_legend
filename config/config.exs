# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :open_legend,
  ecto_repos: [OpenLegend.Repo]

config :open_legend, OpenLegend.Repo,
       migration_timestamps: [type: :naive_datetime_usec]

# Configures the endpoint
config :open_legend, OpenLegendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4q3Hlo+t9kAwQXQI549h/bFz/AzBH0Ye5s5UBWP+EDMrUMv8pYJdlWJpZkLfESHw",
  render_errors: [view: OpenLegendWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OpenLegend.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :surface,
  error_helpers: OpenLegendWeb.ErrorHelpers

config :open_legend, :generators,
  migration: true,
  binary_id: true,
  sample_binary_id: "11111111-1111-1111-1111-111111111111"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
