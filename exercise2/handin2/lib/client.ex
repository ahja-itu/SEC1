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
    if Utils.keep_playing?, do: schedule_next_game()

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










    # Rolling a dice for own part of the dice roll + generating bit string + commitment
    roll = Game.dice_roll()
    Logger.info("Rolling dice: #{roll}")

    {bitstring, commitment} =
      roll
      |> Integer.to_string()
      |> Commitments.create()
    Logger.info("Generating bitstring: #{bitstring |> Utils.trunc()}")
    Logger.info("Generating commitment: #{commitment |> Utils.trunc()}")
    Logger.info("Sending commitment to #{other_player}")


    # Roll the composite part of the servers dice roll and gen bitstring + commitment
    composite_roll = Game.dice_roll()
    Logger.info("Rolling composite dice: #{composite_roll}")

    {composite_bitstring, composite_commitment} =
      composite_commitment
      |> Integer.to_string()
      |> Commitments.create()

    Logger.info("Generating composite bitstring: #{composite_bitstring |> Utils.trunc()}")
    Logger.info("Generating composite commitment: #{composite_commitment |> Utils.trunc()}")
    Logger.info("Sending composite commitment to #{other_player}")


    # Build the payload to send to the server
    msg = %{
      "client_commitment" => commitment,
      "composite_commitment" => composite_commitment
    }

    # Make the request
    {_, body} = post("/commit", msg, host: other_player)
    game_id = Map.get(body, "game_id")

    # Unpack the response
    %{
      "game_id" => game_id
      "commitment" => commitment,
      "server_composite_commitment" => composite_commitment,
    } = body

    Logger.info("Received commitment from opponent #{server_commitment |> Utils.trunc()}..")
    Logger.info("Received composite commitment from opponent #{server_composite_commitment |> Utils.trunc()}..")

    # Begin constructing the reveal message
    msg = %{
      "bitstring"           => bitstring,
      "roll"                => roll,
      "composite_bitstring" => server_composite_bitstring,
      "composite_roll"      => server_composite_roll
    }

    %{
      client_state: client_state
      game_id: game_id,
      msg: msg,
      other_player: other_player,
      roll: roll,
      server_commitment: server_commitment,
      server_composite_bitstring: server_composite_bitstring,
      server_composite_roll: server_composite_roll,
    }
  end

  defp send_reveal(game_state) do
    %{
      other_player: other_player,
      msg: msg,
      game_id: game_id,
    } = game_state

    # Making the reveal
    Logger.info("Reveals commitment to opponent")
    {_, body} = post("/reveal/#{game_id}", msg, host: other_player)

    # Unpacking the response
    %{
      "server_bitstring"           => server_bitstring,
      "client_composite_bitstring" => client_composite_bitstring,
      "server_roll"                => server_roll,
      "client_composite_roll"      => client_composite_roll
    } = body

    Logger.info("Received opponent bitstring: #{server_bitstring |> Utils.trunc()}")
    Logger.info("Received opponent roll: #{server_roll}")

    game_state
    |> Map.put(:server_bitstring, server_bitstring)
    |> Map.put(:server_roll, server_roll)
    |> Map.put(:client_composite_bitstring, client_composite_bitstring)
    |> Map.put(:client_composite_roll, client_composite_roll)
  end

  defp verify_game(game_state) do
    # Unpack the state
    %{
      server_commitment: server_commitment,
      server_bitstring: server_bitstring,
      client_composite_commitment: client_composite_commitment,
      client_composite_bitstring: client_composite_bitstring,
      server_roll: server_roll,
      roll: roll,
      client_state: client_state
    } = game_state

    with :ok <- Commitments.verify(server_commitment, server_bitstring),
         :ok <- Commitments.verify(client_composite_commitment, client_composite_bitstring) do

      my_roll = rem(roll + client_composite_roll, 6) + 1
      server_roll = rem(server_roll + server_composite_roll, 6) + 1
      result = game_conclusion(my_roll, server_roll)

      Logger.info("Commitments verified")
      Logger.info("Rolls: client:#{my_roll} vs server:#{server_roll}: #{result}!")
      Logger.info("The game has concluded.")

      update_state_verified(client_state, my_roll, server_roll)
    else
      _ ->
        Logger.error("Commitments not verified:")
        Logger.error("Server commitment: #{server_commitment |> Utils.trunc()}")
        Logger.error("Server bitstring: #{server_bitstring |> Utils.trunc()}")
        Logger.error("Client composite commitment: #{client_composite_commitment |> Utils.trunc()}")
        Logger.error("Client composite bitstring: #{client_composite_bitstring |> Utils.trunc()}")
        client_state
    end
  end

  defp player_name do
    Utils.get_player_name()
  end

  defp update_state_server_cheated(state) do
    Map.update!(state, :server_cheated, &(&1 + 1))
  end

  defp update_state_verified(state, own_roll, server_roll) do
    case game_conclusion(own_roll, server_roll) do
      :draw -> Map.update(state, :draws, 0, &(&1 + 1))
      :win -> Map.update(state, :wins, 0, &(&1 + 1))
      :loss -> Map.update(state, :losses, 0, &(&1 + 1))
    end
  end

  defp game_conclusion(own_roll, server_roll) do
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
