defmodule OpenLegend.Repo.Migrations.CreateGames do
  use OpenLegend.Repo.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :text, null: false
      add :title, :text, null: false
      add :dm_key, :text, null: false
      add :public, :boolean, null: false

      timestamps_with_removed_at()
    end

    create unique_index(:games, [:id], where: "removed_at IS NULL")
    create unique_index(:games, [:slug], where: "removed_at IS NULL")
    create unique_index(:games, [:public], where: "removed_at IS NULL AND public = TRUE")

  end
end
