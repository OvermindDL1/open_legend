defmodule OpenLegend.GameManager.Game do
  use OpenLegend.Repo.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "games" do
    field :slug, :string
    field :title, :string
    field :gm_key, :string
    field :public, :boolean

    has_many :player_characters, __MODULE__.Character, where: [player_id: {:not, nil}, removed_at: nil]
    has_many :non_player_characters, __MODULE__.Character, where: [player_id: nil, removed_at: nil]
    has_many :characters, __MODULE__.Character, where: [removed_at: nil]

    timestamps_with_removed_at()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:slug, :title, :gm_key, :public])
    |> validate_required([:slug, :title, :gm_key, :public])
    |> validate_format(:slug, ~R/[a-zA-Z0-9_:-]{1,32}/)
    |> unique_constraint(:slug)
  end
end
