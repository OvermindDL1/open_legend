defmodule OpenLegend.Repo.Migrations.CreatePlayers do
  use OpenLegend.Repo.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text, null: false
      add :key, :text, null: false

      timestamps_with_removed_at(inserted_at_opts: [primary_key: true])
    end

    create unique_index(:players, [:id], where: "removed_at IS NULL")

  end
end
