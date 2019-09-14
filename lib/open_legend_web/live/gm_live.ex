defmodule OpenLegendWeb.GMLive do
  use Phoenix.LiveView

  alias OpenLegend.GameManager

  def render(assigns) do
    Phoenix.View.render(OpenLegendWeb.GMView, "init.html", assigns)
  end

  def mount(%{game_slug: game_slug, gm_key: gm_key} = session, socket) do
    case GameManager.get_games(slug: game_slug, characters: :pc) do
      [] ->
        {:error, "Game Slug does not exist"}
      [%{gm_key: ^gm_key} = game] ->
        socket =
          socket
          |> assign(:game, game)

        {:ok, socket}
      [_game] ->
        {:error, "Invalid GM Key"}
    end
  end

  def handle_event("bumpy", value, socket) do
    IO.inspect(value, label: BumpyValue)
    #IO.inspect(socket.assigns, label: BumpyAssigns)
    {:noreply, assign(socket, :fullscreen, !socket.assigns[:fullscreen])}
  end
end
