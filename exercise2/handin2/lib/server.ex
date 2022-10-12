defmodule Handin2.Server do
  @moduledoc """
  The server process is the actor that is being talked to. By this, it is the responding party
  to the dice game
  """
  use GenServer
  require Logger

  @type game_state :: :comitted | :revealed

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # Maps game id to a state of
    game_states = Map.new()
    commitments = Map.new()

    {:ok, %{state: game_states, commits: commitments}}
  end

  def send_msg(conn) do
    GenServer.call(__MODULE__, {:msg, conn.body_params})
  end

  def handle_call({:msg, msg = %{"message" => message, "content" => content, "gameid" => gameid}}, _from, state) do
    {{reply, response}, new_state} = act(msg, state)
    {:reply, {reply, %{response: response}}, new_state}
  end

  def handle_call({:msg, msg}, _from, state) do
    Logger.info("Unmatched message received: #{inspect msg}")
    {:reply, :ok, state}
  end

  defp act(msg = %{"message" => message, "content" => content, "gameid" => gameid}, state) do
    case message do
      "commit" -> commit(msg, state)
      "reveal" -> reveal(msg, state)
      _ -> {:error, "Unknown message"}
    end
  end

  defp commit(%{"content" => content, "game" => game}, state) do
    state
  end

  defp reveal(%{"content" => content, "game" => game}, state) do
    state
  end

end
