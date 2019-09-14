defmodule OpenLegendWeb.IndexController do
  use OpenLegendWeb, :controller

  alias OpenLegend.GameManager

  def index(conn, _params) do
    games = GameManager.list_games(public: true)
    render(conn, "index.html", games: games)
  end
end
