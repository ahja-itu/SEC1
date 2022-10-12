defmodule Actor.Protocol do
  @moduledoc """
  This module translates the network messages into protocol instructions.
  """

  def parse(msg) do
    case String.split(msg) do
      _ -> :todo
    end
  end

end
