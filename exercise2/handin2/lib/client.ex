defmodule Handin2.Client do
  require Logger
  use GenServer
  use TypeCheck

  alias Handin2.Commitments

  @headers [{"Content-Type", "application/json"}]

  #
  # Public API
  #

  @spec! start_link(any()) :: {:error, any()} | {:ok, any()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec! init(:ok) :: {:ok, any()}
  def init(:ok) do
    state = %{
      wins: 0,
      losses: 0,
      draws: 0,
      server_cheated: 0,
    }

    timeout = 3
    Logger.info("Player (client) process started. Scheduling to begin playing in #{inspect(timeout)} seconds.", player: player_name())
    schedule_next_game(timeout)

    {:ok, state}
  end

  #
  # Handle callbacks
  #

  def handle_info(:play, state) do
    new_state = case :rand.uniform(5) do
      3 -> play(state)
      _ -> state
    end

    schedule_next_game()
    {:noreply, new_state}
  end


  def terminate(reason, state) do
    Logger.error("Client terminating: #{inspect(reason)}")
    Logger.error("State: #{inspect(state)}")
  end

  #
  # Private functions
  #

  def play(state) do
    other_player = Handin2.Players.get_player()

    roll = :rand.uniform(6)
    {bitstring, commitment} = Commitments.create(roll |> Integer.to_string())

    Logger.info("Rolls #{inspect(roll)}, generates bitstring #{inspect(bitstring |> String.slice(0, 15))}.. and commitment #{inspect(commitment) |> String.slice(0, 15)}. Sends it to opponent",
      player: player_name(), opponent: other_player)

    msg = %{"commitment" => commitment}
    {_, body} = post("/commit", msg, host: other_player)
    game_id = Map.get(body, "game_id")
    server_commitment = Map.get(body, "commitment")
    Logger.info("Received commitment from opponent #{inspect(server_commitment) |> String.slice(0, 15)}..",
      player: player_name(), opponent: other_player)
    msg = %{"bitstring" => bitstring, "roll" => roll}
    Logger.info("Reveals commitment to opponent",
      player: player_name(), opponent: other_player)
    {_, body} = post("/reveal/#{game_id}", msg, host: other_player)

    server_bitstring = Map.get(body, "bitstring")
    server_roll = Map.get(body, "roll")
    Logger.info("Received opponent bitstring #{inspect(server_bitstring) |> String.slice(0, 15)}.. and roll #{inspect(server_roll)} from server",
      player: player_name(), opponent: other_player)

    server_roll_str = server_roll |> Integer.to_string()

    verification = Commitments.verify(server_commitment, server_bitstring, server_roll_str)

    Logger.info("Verifies opponent commitment #{inspect(verification)}",
      player: player_name(), opponent: other_player)

    Logger.info("Game result: own:#{inspect(roll)} vs opponent:#{inspect(server_roll)}. Verdict: #{inspect(determine_winner(roll, server_roll))}",
      player: player_name(), opponent: other_player)

    new_state = case verification do
      :ok -> update_state_verified(state, roll, server_roll)
      :error -> update_state_server_cheated(state)
    end

    schedule_next_game()
    new_state
  end

  defp player_name do
    Application.get_env(:handin2, :player_name)
  end

  defp update_state_server_cheated(state) do
    Map.update!(state, :server_cheated, &(&1 + 1))
  end

  defp update_state_verified(state, own_roll, server_roll) do
    case determine_winner(own_roll, server_roll) do
      :draw -> Map.update(state, :draws,  0, &(&1 + 1))
      :win  -> Map.update(state, :wins,   0, &(&1 + 1))
      :loss -> Map.update(state, :losses, 0, &(&1 + 1))
    end
  end

  defp determine_winner(own_roll, server_roll) do
    cond do
      own_roll == server_roll -> :draw
      own_roll >  server_roll -> :win
      own_roll <  server_roll -> :loss
    end
  end

  defp post(endpoint, body, opts) do
    {:ok, resp} = HTTPoison.post("https://" <> opts[:host] <> endpoint,
      Poison.encode!(body),
      @headers, [hackney: [:insecure]])
    {resp, resp.body |> Poison.decode!()}
  end

  defp schedule_next_game(timeout \\ 2) do
    Process.send_after(self(), :play, :timer.seconds(timeout))
  end
end
