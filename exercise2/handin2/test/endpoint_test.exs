defmodule Handin2.Endpoint.Test do
  use ExUnit.Case

  @host "https://localhost:4040"
  @headers [{"Content-Type", "application/json"}]

  describe "/commit" do
    test "creates a new game" do
      commit = "aopwefawoef"
      msg = %{"commitment" => commit}

      {resp, body} = post("/commit", msg)

      assert Map.get(body, "commitment") != nil
      assert Map.get(body, "game_id") != nil
    end
  end

  describe "/reveal" do
    test "server reveals their commit" do
      roll = 6
      bitstring = Handin2.Utils.gen_bitstring()
      commitment = bitstring <> Integer.to_string(roll) |> Handin2.Utils.hash()

      # Create commitment
      msg = %{"commitment" => commitment}

      {resp, body} = post("/commit", msg)
      game_id = Map.get(body, "game_id")

      msg = %{"bitstring" => bitstring, "roll" => roll}
      {resp, body} = post("/reveal/#{game_id}", msg)

      winner = Map.get(body, "winner")
      assert winner == "client" or winner == "draw"
    end

    test "server reveals correct commitment" do
      roll = 6
      bitstring = Handin2.Utils.gen_bitstring()
      commitment = bitstring <> Integer.to_string(roll) |> Handin2.Utils.hash()
      msg = %{"commitment" => commitment}
      {resp, body} = post("/commit", msg)
      game_id = Map.get(body, "game_id")
      server_commitment = Map.get(body, "commitment")

      msg = %{"bitstring" => bitstring, "roll" => roll}
      {resp, body} = post("/reveal/#{game_id}", msg)

      server_bitstring = Map.get(body, "bitstring")
      server_roll = Map.get(body, "roll") |> Integer.to_string()

      server_commitment_reconstructed = server_bitstring <> server_roll |> Handin2.Utils.hash()

      assert server_commitment_reconstructed == server_commitment
    end
  end


  def post(endpoint, body) do
    {:ok, resp} = HTTPoison.post(@host <> endpoint,
      Poison.encode!(body),
      @headers, [hackney: [:insecure]])
    {resp, resp.body |> Poison.decode!()}
  end
end
