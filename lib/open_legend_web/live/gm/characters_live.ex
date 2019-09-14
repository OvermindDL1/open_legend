defmodule OpenLegendWeb.GM.CharactersLive do
  use Phoenix.LiveView

  alias OpenLegend.GameManager
  alias Ecto.Changeset

  defmodule SelectedCharacters do
    use Ecto.Schema
    schema "selected_characters" do
      field :selected, {:array, :string}
    end
  end


  def render(assigns) do
    Phoenix.View.render(OpenLegendWeb.GMView, "characters.html", assigns)
  end

  def mount(%{game_slug: game_slug, gm_key: gm_key, id: id} = session, socket) do
    case GameManager.get_games(slug: game_slug, characters: :all) do
      [] ->
        {:error, "Game Slug does not exist"}
      [%{gm_key: ^gm_key} = game] ->

        selected_characters_changeset = Changeset.cast(%SelectedCharacters{}, %{selected: []}, [:selected])

        socket =
          socket
          |> assign(:id, id)
          |> assign(:game, game)
          |> assign(:sort, :all)
          |> assign(:selected_characters_changeset, selected_characters_changeset)

        {:ok, socket}
      [_game] ->
        {:error, "Invalid GM Key"}
    end
  end

  def handle_event("select_characters", %{"selected_characters" => selected_characters}, socket) do
    selected_characters_changeset = Changeset.cast(%SelectedCharacters{}, selected_characters, [:selected])
    {:noreply, assign(socket, :selected_characters_changeset, selected_characters_changeset)}
  end

  def handle_event("sort", %{"sort" => sort}, socket) do
    sort = case sort do
      "all" -> :all
      "npc" -> :npc
      "pc" -> :pc
    end
    socket =
      socket
      |> assign(:sort, sort)
    {:noreply, socket}
  end

#  def handle_event(key, value, socket) do
#    IO.inspect({key, value}, label: :UnhandledLiveEvent)
#    {:noreply, socket}
#  end
end
