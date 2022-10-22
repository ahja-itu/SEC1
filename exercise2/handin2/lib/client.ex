defmodule Handin2.Client do
  require Logger
  use GenServer
  use TypeCheck

  alias Handin2.{Game, Commitments, Utils, Security}

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
    schedule_games_if_playing()
    {:ok, gen_new_state()}
  end

  #
  # Handle callbacks
  #

  def handle_info(:play, state) do
    new_state = play(state)
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

  defp play(state) do
    {Utils.get_opponent_name(), state}
    |> send_commitment()
    |> send_reveal()
    |> verify_game()
  end

  defp send_commitment({other_player, client_state}) do
    roll = Game.dice_roll()

    {bitstring, commitment} = Commitments.create(roll |> Integer.to_string())

    Logger.info(
      "Rolls #{inspect(roll)}, generates bitstring #{bitstring |> Utils.trunc()} and commitment #{commitment |> Utils.trunc()}. Sends it to opponent"
    )

    msg = %{"commitment" => commitment}
    {_, body} = post("/commit", msg, host: other_player)
    game_id = Map.get(body, "game_id")
    server_commitment = Map.get(body, "commitment")

    Logger.info("Received commitment from opponent #{server_commitment |> Utils.trunc()}..")

    msg = %{"bitstring" => bitstring, "roll" => roll}

    %{
      other_player: other_player,
      server_commitment: server_commitment,
      msg: msg,
      game_id: game_id,
      roll: roll,
      client_state: client_state
    }
  end

  defp send_reveal(game_state) do
    %{
      other_player: other_player,
      server_commitment: server_commitment,
      msg: msg,
      game_id: game_id,
      client_state: client_state
    } = game_state

    Logger.info("Reveals commitment to opponent")
    {_, body} = post("/reveal/#{game_id}", msg, host: other_player)

    server_bitstring = Map.get(body, "bitstring")
    server_roll = Map.get(body, "roll")

    Logger.info(
      "Received opponent bitstring #{server_bitstring |> Utils.trunc()} and roll #{inspect(server_roll)} from server"
    )

    Map.put(game_state, :server_bitstring, server_bitstring)
    |> Map.put(:server_roll, server_roll)
  end

  defp verify_game(game_state) do
    # Unpack the state
    %{
      server_commitment: server_commitment,
      server_bitstring: server_bitstring,
      server_roll: server_roll,
      roll: roll,
      other_player: other_player,
      client_state: client_state
    } = game_state

    # Convert the server received server roll to a string
    server_roll_str = server_roll |> Integer.to_string()

    # Verify the opening with the previously received commitment
    verification = Commitments.verify(server_commitment, server_bitstring, server_roll_str)

    Logger.info("Verifies opponent commitment #{inspect(verification)}")

    winner = determine_winner(roll, server_roll)

    Logger.info(
      "Game result: own:#{inspect(roll)} vs opponent:#{inspect(server_roll)}. Verdict: #{inspect(winner)}"
    )

    Logger.info("The game has concluded.")

    case verification do
      :ok -> update_state_verified(client_state, roll, server_roll)
      :error -> update_state_server_cheated(client_state)
    end
  end

  defp player_name do
    Utils.get_player_name()
  end

  defp update_state_server_cheated(state) do
    Map.update!(state, :server_cheated, &(&1 + 1))
  end

  defp update_state_verified(state, own_roll, server_roll) do
    case determine_winner(own_roll, server_roll) do
      :draw -> Map.update(state, :draws, 0, &(&1 + 1))
      :win -> Map.update(state, :wins, 0, &(&1 + 1))
      :loss -> Map.update(state, :losses, 0, &(&1 + 1))
    end
  end

  defp determine_winner(own_roll, server_roll) do
    cond do
      own_roll == server_roll -> :draw
      own_roll > server_roll -> :win
      own_roll < server_roll -> :loss
    end
  end

  defp post(endpoint, body, opts) do
    {:ok, resp} =
      HTTPoison.post(
        "https://" <> opts[:host] <> endpoint,
        Poison.encode!(body),
        @headers,
        req_opts()
      )

    {resp, resp.body |> Poison.decode!()}
  end

  defp req_opts do
    [
      ssl: [
        versions: [:"tlsv1.2"],
        verify: :verify_peer,
        cacertfile: Security.config(:cacert),
        certfile: Security.config(:cert),
        keyfile: Security.config(:privatekey),
        ciphers: :ssl.cipher_suites(:all, :"tlsv1.2"),
        depth: 3,
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]
  end

  defp schedule_next_game(timeout \\ 2) do
    Process.send_after(self(), :play, :timer.seconds(timeout))
  end

  defp schedule_games_if_playing() do
    case Utils.is_playing?() do
      true ->
        schedule_next_game()

      false ->
        :ok
    end
  end

  defp gen_new_state() do
    %{
      wins: 0,
      losses: 0,
      draws: 0,
      server_cheated: 0
    }
  end
end
