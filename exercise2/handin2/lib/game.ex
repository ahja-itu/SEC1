defmodule Handin2.Game do
  @moduledoc """
  This module allows the server to keep track of multiple game states, such that multiple clients can
  play with a single server
  """

  @type game_state :: :ready | :revealed | :comitted

  def new do
    Map.new()
  end

  def new_game(game_state) do
    new_game_id = :crypto.strong_rand_bytes(256) |> Base.encode16()

    case Map.get(game_state, new_game_id) do
      nil ->
        game_state
        |> Map.put(new_game_id, :ready)
        |> then(&{new_game_id, &1})
      _ -> new_game(game_state)
    end
  end

  def get_game_state(game_state, game_id) do
    Map.get(game_state, game_id)
  end

  def promote_state(game_state, game_id) do
    case Map.get(game_state, game_id) do
      :ready    -> game_state |> {:ok, Map.put(game_id, :comitted)}
      :comitted -> game_state |> {:ok, Map.put(game_id, :revealed)}
      :revealed -> game_state |> {:ok, Map.delete(game_id)}
      _         ->               {:error, game_state}
    end
  end


end
