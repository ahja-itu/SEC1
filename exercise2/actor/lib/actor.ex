defmodule Actor do
  use GenServer
  use TypeCheck
  require Logger

  @typedoc """
  Represents the state which the actor is in. This controls
  which actions are legal to take at any given time. Illegal actions will
  provoke an error.
  """
  @type! actor_state :: :ready |
                       :ac
  @type! actor_role :: :undetermined | :server | :client

  defstruct own_id: nil,
            opponent_id: nil,
            state: :ready,
            role: :undetermined,
            commitment_bit_string: nil

  # Public functions

  @spec! start_link() :: {:ok, pid()}
  def start_link() do

    state =
      new([
        own_id: Networking.Settings.get_own_id,
        state: :ready,
        role: :undetermined,
        commitment_bit_string: nil
      ])

    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state}
  end

  @spec! set_own_id(pid(), String.t()) :: :ok
  def set_own_id(pid, id) do
    GenServer.call(pid, {:set_own_id, id})
  end

  @spec! set_opponent_id(pid(), String.t()) :: :ok
  def set_opponent_id(pid, id) do
    GenServer.call(pid, {:set_opponent_id, id})
  end

  @spec! set_role(pid(), actor_role()) :: :ok
  def set_role(pid, role) do
    GenServer.call(pid, {:set_role, role})
  end

  # Callbacks

  ## Setters
  def handle_call({:set_own_id, id}, _from, state) do
    {:reply, :ok, %{state | own_id: id}}
  end

  def handle_call({:set_opponent_id, id}, _from, state) do
    {:reply, :ok, %{state | opponent_id: id}}
  end

  def handle_call({:set_role, role}, _from, state) do
    {:reply, :ok, %{state | role: role}}
  end

  ## Debugging
  def handle_call({:msg, msg}, _from, state) do
    Logger.info("Received message: #{inspect(msg)}")
    {:reply, :ok, state}
  end

  # Private functions
  defp new(args), do: Map.merge(%__MODULE__{}, Map.new(args))
end
