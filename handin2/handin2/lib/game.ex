defmodule Handin2.Game do
  require Logger
  use TypeCheck

  alias Handin2.{Utils, Roll, Security}

  @faces 6
  @headers [{"Content-Type", "application/json"}]

  defstruct client_roll: :unset,
            server_roll: :unset,
            server_host: "",
            server_name: ""

  def new() do
    opponent_host = Utils.get_opponent_name()

    %Handin2.Game{
      client_roll: Roll.new("client"),
      server_roll: Roll.new("server"),
      server_host: opponent_host,
      server_name: opponent_host |> String.split(":") |> List.first()
    }
  end

  def commit(game) do
    msg = %{
      "client_roll_commitment" => game.client_roll.local_commitment,
      "server_roll_commitment" => game.server_roll.local_commitment,
    }

    Logger.info("Making commitments to server")
    %{
      "client_roll_commitment" => client_roll_commitment,
      "server_roll_commitment" => server_roll_commitment,
      "game_id" => game_id
    } = post("/commit", msg, game.server_host)

    updated_game =
      game
      |> Map.update!(:client_roll, &(Roll.add_remote_commitment(&1, client_roll_commitment)))
      |> Map.update!(:server_roll, &(Roll.add_remote_commitment(&1, server_roll_commitment)))

    {updated_game, game_id}
  end

  def reveal(game, game_id) do
    msg = %{
      "client_roll" => game.client_roll.local_roll,
      "server_roll" => game.server_roll.local_roll,
      "client_bitstring" => game.client_roll.local_roll_bitstring,
      "server_bitstring" => game.server_roll.local_roll_bitstring,
    }

    Logger.info("Revealing commitments to server")

    body = post("/reveal/#{game_id}", msg, game.server_host)

    %{
      "client_roll" => client_roll,
      "server_roll" => server_roll,
      "client_bitstring" => client_bitstring,
      "server_bitstring" => server_bitstring,
    } = body

    {:ok, new_client_roll} = Roll.verify_remote_commitment(game.client_roll, client_roll, client_bitstring)
    {:ok, new_server_roll} = Roll.verify_remote_commitment(game.server_roll, server_roll, server_bitstring)

    Logger.info("The servers commitments were valid!")

    %{ game | client_roll: new_client_roll, server_roll: new_server_roll }
  end

  def respond_commit(game, game_id, msg) do
    %{
      "client_roll_commitment" => client_roll_commitment,
      "server_roll_commitment" => server_roll_commitment,
    } = msg

    updated_game =
      game
      |> Map.update!(:client_roll, &(Roll.add_remote_commitment(&1, client_roll_commitment)))
      |> Map.update!(:server_roll, &(Roll.add_remote_commitment(&1, server_roll_commitment)))
    Logger.info("Reveals commitment to client")

    {updated_game,
      %{
        "game_id" => game_id,
        "client_roll_commitment" => updated_game.client_roll.local_commitment,
        "server_roll_commitment" => updated_game.server_roll.local_commitment,
      }}
  end

  def respond_reveal(game, msg) do
    %{
      "client_roll" => client_roll,
      "server_roll" => server_roll,
      "client_bitstring" => client_bitstring,
      "server_bitstring" => server_bitstring,
    } = msg

    with {:ok, new_client_roll} <- Roll.verify_remote_commitment(game.client_roll, client_roll, client_bitstring),
         {:ok, new_server_roll} <- Roll.verify_remote_commitment(game.server_roll, server_roll, server_bitstring) do

      updated_game = %{ game | client_roll: new_client_roll, server_roll: new_server_roll }

      resp = %{
        "client_roll" => new_client_roll.local_roll,
        "server_roll" => new_server_roll.local_roll,
        "client_bitstring" => new_client_roll.local_roll_bitstring,
        "server_bitstring" => new_server_roll.local_roll_bitstring,
      }

      Logger.info("The clients commitments were valid!")

      {:ok, {updated_game, resp}}
    else
      err -> err
    end
  end

  def conclude(game, perspective) do
    client_roll = Roll.calculate_roll(game.client_roll)
    server_roll = Roll.calculate_roll(game.server_roll)
    winner = cond do
      client_roll > server_roll -> if perspective == :server, do: "opponent", else: "me"
      client_roll < server_roll -> if perspective == :server, do: "me", else: "opponent"
      true -> "draw"
    end

    Logger.info("The game is over!")
    Logger.info("The client rolled #{Roll.calculate_roll(game.client_roll)}")
    Logger.info("The server rolled #{Roll.calculate_roll(game.server_roll)}")
    Logger.info("Winning party: #{winner}")
  end

  @spec! dice_roll() :: non_neg_integer()
  def dice_roll() do
    :rand.uniform(@faces)
  end

  def get_faces() do
    @faces
  end

  defp post(endpoint, body, addr) do
    {:ok, resp} =
      HTTPoison.post(
        "https://" <> addr <> endpoint,
        Poison.encode!(body),
        @headers,
        req_opts()
      )

    resp.body |> Poison.decode!()
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
end
