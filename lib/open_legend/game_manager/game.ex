defmodule OpenLegend.GameManager.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "games" do
    field :slug, :string
    field :title, :string
    field :dm_key, :string

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:slug, :title, :dm_key])
    |> validate_required([:slug, :title, :dm_key])
  end
end
