defmodule OpenLegend.GameManager do
  @moduledoc """
  The GameManager context.
  """

  import Ecto.Query, warn: false
  alias OpenLegend.Repo

  alias OpenLegend.GameManager.Game

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games(opts \\ []) do
    {public, []} = Keyword.pop(opts, :public, nil)

    query = from(g in Game, where: is_nil(g.removed_at))

    query = case public do
      nil -> query
      public when is_boolean(public) -> where(query, [g], g.public == ^public)
    end

    Repo.all(query)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_games(id: 123)
      %Game{}

      iex> get_games(id: 456)
      ** (Ecto.NoResultsError)

  """
  def get_games(opts) do
    {id, opts} = Keyword.pop(opts, :id, nil)
    {slug, opts} = Keyword.pop(opts, :slug, nil)
    {characters, opts} = Keyword.pop(opts, :characters, nil)
    [] = opts

    query = from(g in Game, as: :game, where: is_nil(g.removed_at))

    query = if id == nil do
      query
    else
      where(query, [g], g.id in ^List.wrap(id))
    end

    query = if slug == nil do
      query
    else
      where(query, [g], g.slug in ^List.wrap(slug))
    end

    results = Repo.all(query)

    results = case characters do
      nil -> results
      :npc ->
        Repo.preload(results, player_characters: from(c in Game.Characters, where: is_nil(c.removed_at) and is_nil(c.player_id)))
        |> Enum.map(fn result ->
          %{result|
            non_player_characters: Map.new(result.non_player_characters, &{&1.name, &1})
          }
        end)
      :pc ->
        Repo.preload(results, player_characters: [:player])
        |> Enum.map(fn result ->
          %{result|
            player_characters: Map.new(result.player_characters, &{&1.name, &1})
          }
        end)
      :all ->
        Repo.preload(results, characters: [:player])
        |> Enum.map(fn result ->
          %{result|
            characters: Map.new(result.characters, &{&1.name, &1})
          }
        end)
        |> Enum.map(fn result ->
          {npc, pc} = Enum.split_with(result.characters, &(elem(&1, 1).player_id == nil))
          npc = Map.new(npc)
          pc = Map.new(pc)
          %{result|
            player_characters: pc,
            non_player_characters: npc,
          }
        end)
    end

    results
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{source: %Game{}}

  """
  def change_game(%Game{} = game) do
    Game.changeset(game, %{})
  end
end
