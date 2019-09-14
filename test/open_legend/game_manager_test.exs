defmodule OpenLegend.GameManagerTest do
  use OpenLegend.DataCase

  alias OpenLegend.GameManager

  describe "games" do
    alias OpenLegend.GameManager.Game

    @valid_attrs %{slug: "some slug", title: "some title"}
    @update_attrs %{slug: "some updated slug", title: "some updated title"}
    @invalid_attrs %{slug: nil, title: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GameManager.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert GameManager.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert GameManager.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = GameManager.create_game(@valid_attrs)
      assert game.slug == "some slug"
      assert game.title == "some title"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GameManager.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, %Game{} = game} = GameManager.update_game(game, @update_attrs)
      assert game.slug == "some updated slug"
      assert game.title == "some updated title"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = GameManager.update_game(game, @invalid_attrs)
      assert game == GameManager.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = GameManager.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> GameManager.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = GameManager.change_game(game)
    end
  end
end
