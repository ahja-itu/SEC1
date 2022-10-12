defmodule Helpers do
  @moduledoc """
  Contains helper functions for the project.
  """

  use Bitwise
  use TypeCheck

  require Integer





  @spec! pow(integer(), integer()) :: integer()
  def pow(base, exp) do
    if exp < 0,
      do: do_slow_pow(base, exp, exp),
      else: do_sq_pow2(base, exp, 1)
  end

  defp do_sq_pow(base, exp, res) do
    # Implementation after https://stackoverflow.com/questions/101439/the-most-efficient-way-to-implement-an-integer-based-power-function-powint-int
    res_buff = if (exp &&& 0b1) == 1, do: res * base, else: res
    if exp == 0, do: res_buff, else: do_sq_pow(base * base, exp >>> 1, res_buff)
  end

  defp do_sq_pow2(_, 0, _), do: 1
  defp do_sq_pow2(_, 1, res), do: res
  defp do_sq_pow2(base, exp, res) do
    # Implementation of
    # https://programming-idioms.org/idiom/32/integer-exponentiation-by-squaring/932/elixir
    IO.inspect({base, exp, res}, label: "do_sq_pow2 {base, exp, res}")
    if Integer.is_even(exp),
      do: do_sq_pow2(base * base, div(exp, 2), res),
      else: do_sq_pow2(base * base, div(exp - 1, 2), res * base)
  end

  defp do_slow_pow(base, exponent, acc) when exponent < 0 do
    acc / do_sq_pow(base, abs(exponent), 1)
  end

end
