defmodule OpenLegendWeb.Router do
  use OpenLegendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OpenLegendWeb do
    pipe_through :browser

    get "/", IndexController, :index

    get "/games/create", GamesController, :create
    post "/games/create", GamesController, :creating

    get "/games/join/:game_slug", GamesController, :join

    post "/game/:game_slug/gm", GMController, :init
    post "/game/:game_slug/pc/:pc_name", PCController, :init
  end
end

# Other scopes may use custom stacks.
# scope "/api", OpenLegendWeb do
#   pipe_through :api
# end
