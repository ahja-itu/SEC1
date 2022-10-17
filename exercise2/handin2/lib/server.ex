defmodule Handin2.Server do
  @moduledoc """
  The server process is the actor that is being talked to. By this, it is the responding party
  to the dice game
  """
  use GenServer
  use TypeCheck
  require Logger

  alias Handin2.Game

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
    case Map.has_key?(msg, "commitment") do
      true -> GenServer.call(__MODULE__, {:commit, Map.get(msg, "commitment")})
      false -> {:error, "No commitment in message"}
    end
  end

  @spec! reveal(any, any) :: any
  def reveal(msg, game_id) do
    GenServer.call(__MODULE__, {:reveal, game_id, msg})
  end

  @doc """
  This handler handes the submission of a commitment from the client.
  This signifies a new game.
  """
  def handle_call({:commit, client_commitment}, _from, store) do
    new_game = Handin2.Game.new(client_commitment)

    validate = fn bitstring -> length(:ets.lookup(store, bitstring)) == 0 end

    game_id = Handin2.Utils.gen_bitstring(validate)
    :ets.insert(store, {game_id, new_game})

    commitment = Game.gen_commitment(new_game)

    {:reply, {:ok, %{game_id: game_id, commitment: commitment }}, store}
  end

  def handle_call({:reveal, game_id, %{"bitstring" => bitstring, "roll" => roll}}, _from, store) do
    case :ets.lookup(store, game_id) do
      [{^game_id, game}] ->
        reply = Map.new()
          |> Map.put(:winner, handle_game_lookup(game, bitstring, roll) |> elem(1))
          |> Map.put(:game_id, game_id)
          |> Map.put(:bitstring, game.server_bitstring)
          |> Map.put(:roll, game.server_roll)

        {:reply, {:ok, reply}, store}
      [] ->
        {:reply, {:error, %{message: "No game found by game_id #{inspect game_id}"}}, store}
    end
  end

  def handle_call(msg, _from, state) do
    Logger.error("Unsupported message: #{inspect msg}")
    {:reply, {:error, "Bad request"}, state}
  end

  defp handle_game_lookup(game, bitstring, roll) do
    case Game.check_reveal(game, bitstring, roll) do
      {:ok, conclusion} -> {:ok, conclusion}
      {:error, msg} -> {:error, msg}
    end
  end
end