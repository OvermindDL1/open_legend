# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

env =
  Mix.env()
  |> to_string()
  |> String.upcase()

database_url =
  System.get_env("#{env}_DATABASE_URL") ||
    """
    environment variable #{env}_DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """
    |> if(Mix.env() == :dev, do: &IO.puts/1, else: &raise/1).()

config :open_legend, OpenLegend.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("#{env}_SECRET_KEY_BASE") ||
    """
    environment variable #{env}_SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """
    |> if(Mix.env() == :dev, do: &IO.puts/1, else: &raise/1).()

config :open_legend, OpenLegendWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :open_legend, OpenLegendWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.

signing_salt =
  System.get_env("#{env}_SECRET_KEY_BASE") ||
    """
    environment variable #{env}_}SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """
    |> if(Mix.env() == :dev, do: &IO.puts/1, else: &raise/1).()

config :open_legend, MyAppWeb.Endpoint,
  live_view: [
    signing_salt: signing_salt,
  ]