defmodule OpenLegendWeb.GamesController do
  use OpenLegendWeb, :controller

  def create(conn, _params) do
    render(conn, "create.html")
  end
end
