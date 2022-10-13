defmodule Handin2.Server.Test do
  use ExUnit.Case, async: true

  alias Handin2.{Server, Utils}

  describe "commit" do
    test "creates a new game" do
      msg = %{"commitment" => "hello"}
      {:ok, %{commitment: server_commitment, game_id: game_id}} = Server.commit(msg)

      assert Kernel.is_bitstring(game_id)
      assert Kernel.is_bitstring(server_commitment)
      assert String.length(game_id) > 0
      assert String.length(server_commitment) > 0
    end

    test "fails to create a new game" do
      msg = %{}
      {:error, response} = Server.commit(msg)

      assert Kernel.is_bitstring(response)
      assert String.length(response) > 0
    end
  end

  describe "reveal" do
    test "returns the winner" do
        roll = 6
        bitstring = Utils.gen_bitstring()
        commitment = bitstring <> Integer.to_string(roll) |> Utils.hash()

        msg = %{"commitment" => commitment}
        {:ok, %{game_id: game_id}} = Server.commit(msg)

        msg = %{"bitstring" => bitstring, "roll" => roll}
        {:ok, resp} = Server.reveal(msg, game_id)

        assert resp.winner == :client or resp.winner == :draw
    end
  end


end
