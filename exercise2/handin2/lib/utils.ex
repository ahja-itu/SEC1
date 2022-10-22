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

  @spec! get_player_name() :: String.t()
  def get_player_name() do
    Application.get_env(:handin2, :player_name)
  end

  @spec! get_opponent_name() :: String.t()
  def get_opponent_name() do
    Application.get_env(:handin2, :player_names) |> Enum.random()
  end

  @spec! is_playing?() :: boolean()
  def is_playing?() do
    Application.get_env(:handin2, :is_playing)
  end

  @spec! trunc(String.t()) :: String.t()
  def trunc(str) do
    truncated =
      if get_trunc_length() >= 1,
        do: String.slice(str, 0..get_trunc_length()) <> "...",
        else: str

    "\"" <> truncated <> "\""
  end

  defp get_trunc_length() do
    Application.get_env(:handin2, :trunc_length)
  end
end
