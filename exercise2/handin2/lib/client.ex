defmodule Handin2.Client do
  require Logger
  use GenServer
  use TypeCheck

  alias Handin2.{Commitments, Utils}
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
    {:ok, state}
  end

  def play_game(other_player) do
    case GenServer.call(__MODULE__, {:play_game, other_player}) do
      {:ok, result} ->
        Logger.info("Game played successfully! Result: #{result}")
        :ok
      {:error, _} ->
        Logger.info("Game failed! The server may have cheated.")
        :error
    end
  end

  #
  # Handle callbacks
  #

  def handle_call({:play_game, other_player}, _from, state) do
    roll = :rand.uniform(6)
    {bitstring, commitment} = Commitments.create(roll |> Integer.to_string())

    msg = %{"commitment" => commitment}
    {_, body} = post("/commit", msg, host: other_player)
    game_id = Map.get(body, "game_id")
    server_commitment = Map.get(body, "commitment")

    msg = %{"bitstring" => bitstring, "roll" => roll}
    {_, body} = post("/reveal/#{game_id}", msg, host: other_player)

    server_bitstring = Map.get(body, "bitstring")
    server_roll = Map.get(body, "roll") |> String.to_integer()

    server_roll_str = server_roll |> Integer.to_string()

    verification = Commitments.verify(server_commitment, server_bitstring, server_roll_str)
    new_state = case verification do
      :ok -> update_state_verified(state, roll, server_roll)
      :error -> update_state_server_cheated(state)
    end

    {:reply, {verification, determine_winner(roll, server_roll)}, new_state}
  end

  defp update_state_server_cheated(state) do
    Map.update!(state, :server_cheated, &(&1 + 1))
  end

  defp update_state_verified(state, own_roll, server_roll) do
    case determine_winner(own_roll, server_roll) do
      :draw -> Map.update(state, :draws,  1, &(&1 + 1))
      :win  -> Map.update(state, :wins,   1, &(&1 + 1))
      :loss -> Map.update(state, :losses, 1, &(&1 + 1))
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
    {:ok, resp} = HTTPoison.post(opts[:host] <> endpoint,
      Poison.encode!(body),
      @headers, [hackney: [:insecure]])
    {resp, resp.body |> Poison.decode!()}
  end

end
