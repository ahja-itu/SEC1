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

  def trunc(str) do
    truncated =
      if get_trunc_length() >= 1,
        do: String.slice(str, 0..get_trunc_length()) <> "...",
        else: str

    "\"" <> truncated <> "\""
  end

  @spec! keep_playing?() :: boolean()
  def keep_playing?() do
    Application.get_env(:handin2, :keep_playing)
  end

  defp encode(bitstring) do
    bitstring |> Base.encode64() |> String.replace("/", "_")
  end

  defp get_trunc_length() do
    Application.get_env(:handin2, :trunc_length)
  end

  def new_unique_id(store) do
    fn bitstring -> length(:ets.lookup(store, bitstring)) == 0 end
    |> Handin2.Utils.gen_bitstring()
  end
end
