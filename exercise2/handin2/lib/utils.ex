defmodule Handin2.Utils do
  use TypeCheck

  @hash_algo :sha3_512

  def get_hash_algo do
    @hash_algo
  end

  @spec! hash(String.t()) :: String.t()
  def hash(msg) do
    :crypto.hash(@hash_algo, msg)
  end

  @spec! apply_arith(binary(), fun()) :: integer()
  def apply_arith(str, fun) do
    :binary.decode_unsigned(str) |> fun.()
  end

  @spec! apply_arith_to_str(binary(), fun()) :: binary()
  def apply_arith_to_str(str, fun) do
    apply_arith(str, fun) |> :binary.encode_unsigned()
  end
end
