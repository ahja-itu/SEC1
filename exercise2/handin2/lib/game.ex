defmodule Handin2.Game do
  use TypeCheck

  alias Handin2.{Utils, Commitments}

  defstruct client_commit: :unset,
            server_roll: :unset,
            server_bitstring: :unset

  @spec! new(String.t()) :: map()
  def new(client_commitment) do
    %Handin2.Game{
      client_commit: client_commitment,
      server_roll: :rand.uniform(6),
      server_bitstring: Utils.gen_bitstring(),
    }
  end

  @spec! gen_commitment(%Handin2.Game{}) :: binary()
  def gen_commitment(game) do
    Commitments.create(game.server_bitstring, game.server_roll |> Integer.to_string()) |> elem(1)
  end

  @spec! gen_commitment(binary(), binary()) :: binary()
  def gen_commitment(bitstring, msg) do
    Commitments.create(bitstring, msg) |> elem(1)
  end

  def check_reveal(game, bitstring, roll) do
    case Commitments.verify(game.client_commit, bitstring, roll |> Integer.to_string()) do
      :ok -> {:ok, determine_winner(game, roll)}
      :error -> {:error, "Commitment does not match"}
    end
  end

  defp determine_winner(game, client_roll) do
    cond do
      game.server_roll == client_roll -> :draw
      game.server_roll > client_roll -> :server
      game.server_roll < client_roll -> :client
    end
  end
end
