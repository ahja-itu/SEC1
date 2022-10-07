defmodule Commitments do


  @hash_algo :sha256
  @bitstring_length 256

  @doc """
  Creates a commitment to a message.
  Generates a random bitstring of length 256 and hashes it with the message.
  Returns the random bitstring and the hash.
  """
  @spec create(String.t()) :: {String.t(), String.t()}
  def create(msg) do
    :crypto.strong_rand_bytes(@bitstring_length)
    |> Kernel.<>(msg)
    |> then(&{&1, :crypto.hash(@hash_algo, &1)})
  end

  @doc """
  Verifies a commitment.
  Hashes the random bitstring with the message and compares it to the hash.
  Returns :ok if the hashes match, :error otherwise.
  """
  @spec verify(String.t(), String.t()) :: :ok | :error
  def verify(hash, rmsg) do
    case hash == :crypto.hash(@hash_algo, rmsg) do
      true -> :ok
      false -> :error
    end
  end
end
