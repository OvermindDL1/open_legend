defmodule OpenLegend.GameManager.Game.Character do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "game_characters" do
    field :name, :string
    field :game_id, :binary_id
    field :player_id, :binary_id

    belongs_to :game, OpenLegend.GameManager.Game, define_field: false, where: [removed_at: nil]
    belongs_to :player, OpenLegend.GameManager.Player, define_field: false, where: [removed_at: nil]

    timestamps()
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:name, :game_id, :player_id])
    |> validate_required([:name, :game_id])
  end
end
