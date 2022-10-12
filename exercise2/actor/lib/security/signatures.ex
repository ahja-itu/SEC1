defmodule Security.Signatures do
  @moduledoc """
  This module implements the El Gamal signature scheme.
  """

  @doc """
  Generates a key pair for digital signatures given a generator g and a prime number p.
  Assumes the group to be of multiplicative notation over the group of integers modulo p.
  """
  @spec generate_keys(Integer.t(), Integer.t()) :: :ok
  def generate_keys(g, p) do
    # Implementation after https://learnit.itu.dk/pluginfile.php/327574/mod_resource/content/2/slides.pdf p. 25
    # g is generator
    # p is the prime
    # Group assumed to be a multiplicative group over integers of order p

    sk = :rand.uniform(p) - 1 # Ensures sk 0 <= sk <= p-1
    pk = rem(:math.pow(g, sk), p)
    {sk, pk}
  end

  @spec sign(binary(), integer(), integer(), integer()) :: {integer(), binary()}
  def sign(msg, sk, g, p) do
    # implementation of https://learnit.itu.dk/pluginfile.php/327574/mod_resource/content/2/slides.pdf p. 25
    k = :rand.uniform(p-1) # Ensures k 1 <= r <= p-1
    r = create_key(g, k, p)

    numerator = Security.Core.apply_arith(msg, fn m -> m - sk * r end)
    signature = rem(div(numerator, k), p-1)
    case signature do
      0 -> sign(msg, sk, g, p)
      _ -> {r, :binary.encode_unsigned(signature)}
    end
  end

  def verify({r, signature}, msg, g, p, pk) do
    s = :binary.decode_unsigned(signature)
    0 < r and r < p and 0 < s and s < (p-1) and verify_hash(g, msg, pk, r, s)
  end

  defp verify_hash(g, m, pk, r, s) do
    Security.Core.apply_arith(Security.Core.hash(m), fn hm -> Helpers.pow(g, hm) end) == Helpers.pow(pk, r) * Helpers.pow(r, s)
  end

  def create_key(base, exponent, prime) do
    # Calculates `base^exponent mod prime`
    :crypto.mod_pow(base, exponent, prime) |> :binary.decode_unsigned()
  end
end
