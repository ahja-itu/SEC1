defmodule Handin2.Players do
  @moduledoc """
  This module accepts configuration from the environment
  to instruct the client which players it can play with
  """

  def get_player() do
    Application.get_env(:handin2, :player_names) |> Enum.random()
  end
end
