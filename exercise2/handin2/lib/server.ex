defmodule Handin2.Server do
  @moduledoc """
  The server process is the actor that is being talked to. By this, it is the responding party
  to the dice game
  """
  use GenServer
  use TypeCheck
  require Logger

  alias Handin2.{Game, Utils}

  #
  # Public API
  #

  @spec! start_link(any()) :: {:error, any()} | {:ok, any()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec! init(:ok) :: {:ok, any()}
  def init(:ok) do
    {:ok, :ets.new(:store, [:set, :public])}
  end

  def commit(msg) do
      GenServer.call(__MODULE__, {:commit, msg})
  end

  @spec! reveal(any, any) :: any
  def reveal(msg, game_id) do
    GenServer.call(__MODULE__, {:reveal, game_id, msg})
  end

  def handle_call({:commit, msg}, _from, store) do
    game_id = Utils.new_unique_id(store)

    {game, response} = Game.new() |> Game.respond_commit(game_id, msg)

    :ets.insert(store, {game_id, game})

    {:reply, {:ok, response}, store}
  end

  def handle_call({:reveal, game_id, msg}, _from, store) do
    case :ets.lookup(store, game_id) do
      [{^game_id, game}] ->
        {:ok, {updated_game, response}} = Game.respond_reveal(game, msg)
        # TODO: can conclude game
        Game.conclude(updated_game, :server)

        {:reply, {:ok, response}, store}
      [] ->
        {:reply, {:error, %{message: "No game found by game_id #{game_id |> Utils.trunc()}"}},
         store}
    end
  end

  def handle_call(msg, _from, state) do
    Logger.error("Unsupported message: #{inspect(msg)}")
    {:reply, {:error, "Bad request"}, state}
  end
end
