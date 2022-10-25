defmodule Handin2.Roll do
  require Logger

  defstruct local_roll: :unset,
            local_roll_bitstring: :unset,
            local_commitment: :unset,
            remote_roll: :unset,
            remote_roll_bitstring: :unset,
            remote_commitment: :unset,
            roll_owner: :unset

  alias Handin2.{Utils, Commitments, Game}
  @doc """
  Returns a new roll where it makes the local roll and commitment
  """
  def new(roll_owner) do
    local_roll = Game.dice_roll()
    {local_bitstring, local_commitment} =
        local_roll
        |> Integer.to_string()
        |> Commitments.create()

    Logger.info("Rolled for #{roll_owner} #{local_roll}")
    Logger.info("Bitstring for #{roll_owner} roll: #{local_bitstring |> Utils.trunc()}")
    Logger.info("Commitment for #{roll_owner} roll: #{local_commitment |> Utils.trunc()}")

    %Handin2.Roll{
      local_roll: local_roll,
      local_roll_bitstring: local_bitstring,
      local_commitment: local_commitment,
      roll_owner: roll_owner
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
        case remote_roll > Game.get_faces() do
          true ->
            Logger.error("Remote roll is too high: #{remote_roll}")
            raise "Remote roll is too high: #{remote_roll}"
          false ->
            Logger.info("Verified remote composite roll: #{remote_roll}, bitstring: #{remote_bitstring |> Utils.trunc()}, commitment: #{roll.remote_commitment |> Utils.trunc()}")
            updated_roll = %Handin2.Roll{
              roll | remote_roll: remote_roll,
              remote_roll_bitstring: remote_bitstring
            }
            {:ok, updated_roll }
        end

      :error ->
        Logger.error("Failed to verify remote composite roll")
        raise "Could not verify remote composite roll"
    end
  end

  def calculate_roll(roll) do
    value = rem(roll.local_roll + roll.remote_roll, Game.get_faces()) + 1
  end
end
