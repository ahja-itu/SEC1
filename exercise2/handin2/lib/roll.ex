defmodule Handin2.Roll do
  require Logger

  defstruct local_roll: :unset,
            local_roll_bitstrilng: :unset,
            local_commitment: :unset,
            remote_roll: :unset,
            remote_roll_bitstring: :unset,
            remote_commitment: :unset,

  alias Handin2.{Utils, Commitments, Game}
  @doc """
  Returns a new roll where it makes the local roll and commitment
  """
  def new() do
    local_roll = dice_roll()
    {local_bitstring, local_commitment} =
        local_roll
        |> Integer.to_string()
        |> Commitments.create()

    Logger.info("Rolled #{local_roll}")
    Logger.info("Bitstring: #{local_bitstring |> trunc()}")
    Logger.info("Commitment: #{local_commitment |> trunc()}")

    %Handin2.Roll{
      local_roll: local_roll,
      local_roll_bitstring: local_bitstring,
      local_commitment: local_commitment
    }
  end

  def add_remote_commitment(roll, remote_commitment) do
    %Handin2.Roll{
      roll | remote_commitment: remote_commitment
    }
  end

  def verify_remote_commitment(roll, remote_roll, remote_bitstring) do
    case Commitments.verify(roll.remote_commitment, remote_bitstring, remote_roll |> Integer.to_string()) do
      :ok ->
        Logger.info("Verified remote composite roll")
        updated_roll = %Handin2.Roll{
          roll | remote_roll: remote_roll,
          remote_roll_bitstring: remote_bitstring
        }
        {:ok, updated_roll }
      :error -> {:error, "Commitment does not match"}
    end
  end

  def calculate_roll(roll) do
    value = rem(roll.local_roll + roll.remote_roll, faces()) + 1
  end
end
