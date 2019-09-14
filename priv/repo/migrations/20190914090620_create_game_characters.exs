defmodule OpenLegend.Repo.Migrations.CreateGameCharacters do
  use OpenLegend.Repo.Migration

  def change do
    create table(:game_characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text, null: false

      add :game_id, :binary_id, null: false
      add :player_id, :binary_id, null: true

      timestamps_with_removed_at(inserted_at_opts: [primary_key: true])
    end

    create index(:game_characters, [:game_id])
    create index(:game_characters, [:player_id])
    create index(:game_characters, [:id, :name])
  end
end
