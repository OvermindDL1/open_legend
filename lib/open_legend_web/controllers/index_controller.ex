defmodule OpenLegendWeb.IndexController do
  use OpenLegendWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
