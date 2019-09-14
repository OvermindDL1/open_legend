defmodule OpenLegendWeb.GMController do
  use OpenLegendWeb, :controller

  alias OpenLegend.GameManager

  def init(conn, %{"game_slug" => game_slug, "gm_key" => gm_key} = params) do
    case GameManager.get_games(slug: game_slug, characters: :pc) do
      [] ->
        conn
        |> put_flash(:error, gettext("Game `%slug` does not exist", slug: game_slug))
        |> redirect(to: Routes.index_path(conn, :index))
      [%{gm_key: ^gm_key} = _game] ->
        conn
        |> put_layout({OpenLegendWeb.LayoutView, :base})
        |> live_render(
             OpenLegendWeb.GMLive,
             session: %{game_slug: game_slug, gm_key: gm_key},
             container: {:div, class: "container--wrap w--12"}
           )
      [_game] ->
        conn
        |> put_flash(:error, gettext("Invalid GM key"))
        |> redirect(to: Routes.games_path(conn, :join, game_slug))
    end
#    |> throw
#    throw params
#    changeset = GameManager.Game.changeset(%GameManager.Game{}, %{})
#    render(conn, :gm, changeset: changeset)
  end
end
