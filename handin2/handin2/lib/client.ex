defmodule Handin2.Client do
  require Logger
  use GenServer
  use TypeCheck

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
    schedule_games_if_playing()
    {:ok, :stateless}
  end

  #
  # Handle callbacks
  #

  def handle_info(:play, :stateless) do
    play()
    if Utils.keep_playing?, do: schedule_next_game()

    {:noreply, :stateless}
  end

  def terminate(reason, state) do
    Logger.error("Client terminating: #{inspect(reason)}")
    Logger.error("State: #{inspect(state)}")
  end

  #
  # Private functions
  #

  defp play() do
    send_commitment()
    |> send_reveal()
    |> conclude()
  end

  defp send_commitment() do
    Game.new() |> Game.commit()
  end

  defp send_reveal({game, game_id}) do
    Game.reveal(game, game_id)
  end

  defp conclude(game) do
    Game.conclude(game, :client)
  end

  defp schedule_next_game(timeout \\ 2) do
    Process.send_after(self(), :play, :timer.seconds(timeout))
  end

  defp schedule_games_if_playing() do
    case Utils.is_playing?() do
      true -> schedule_next_game()
      false -> :ok
    end
  end
end
