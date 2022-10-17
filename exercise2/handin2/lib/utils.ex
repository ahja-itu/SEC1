defmodule Handin2.Utils do
  use TypeCheck

  @hash_algo :sha3_512
  @bitstring_length 256

  @spec! get_hash_algo :: atom
  def get_hash_algo do
    @hash_algo
  end

  @spec! hash(String.t()) :: binary()
  def hash(msg) do
    :crypto.hash(@hash_algo, msg) |> encode()
  end

  @spec! apply_arith(binary(), fun()) :: integer()
  def apply_arith(str, fun) do
    :binary.decode_unsigned(str) |> fun.()
  end

  @spec! apply_arith_to_str(binary(), fun()) :: binary()
  def apply_arith_to_str(str, fun) do
    apply_arith(str, fun) |> :binary.encode_unsigned()
  end

  @spec! gen_bitstring() :: String.t()
  def gen_bitstring() do
    :crypto.strong_rand_bytes(@bitstring_length) |> encode()
  end

  @spec! gen_bitstring((String.t() -> boolean())) :: String.t()
  def gen_bitstring(checker) do
    bitstring = gen_bitstring()
    case checker.(bitstring) do
      false -> gen_bitstring(checker)
      true -> bitstring
    end
  end

  defp encode(bitstring) do
    bitstring |> Base.encode64() |> String.replace("/", "_")
  end
end
