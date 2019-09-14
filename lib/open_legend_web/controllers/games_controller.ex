defmodule OpenLegendWeb.GamesController do
  use OpenLegendWeb, :controller

  alias OpenLegend.GameManager

  def create(conn, _params) do
    changeset = GameManager.Game.changeset(%GameManager.Game{}, %{})
    render(conn, :create, changeset: changeset)
  end

  def creating(conn, %{"game" => game_attrs} = _params) do
    case GameManager.create_game(game_attrs) do
      {:ok, game} ->
        conn
        |> put_flash(:info, gettext("Created Game `%{slug}`: %{title}", slug: game.slug, title: game.title))
        |> redirect(to: Routes.index_path(conn, :index))
        {:error, changeset} ->
        render(conn, :create, changeset: changeset)
    end
  end

  def join(conn, %{"game_slug" => game_slug} = _params) do
    case GameManager.get_games(slug: game_slug, characters: :pc) do
      [] ->
        conn
        |> put_flash(:error, gettext("Game `%{game}` does not exist", game: game_slug))
        |> redirect(to: Routes.index_path(conn, :index))
      [game] ->
        render(conn, :join, game: game)
    end
  end
end
