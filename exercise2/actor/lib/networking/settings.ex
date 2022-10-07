defmodule Networking.Settings do
  use Agent

  def start_link(_) do
    port = System.get_env("PORT") || 4000
    own_id = System.get_env("OWN_ID") || "UNKNOWN"

    Agent.start_link(fn -> %{port: port, own_id: own_id} end, name: __MODULE__)
  end

  def import_args(args) do
    Agent.update(__MODULE__, fn settings ->
      Map.merge(settings, Map.new(args))
    end)
  end

  def get_port, do: Agent.get(__MODULE__, & &1[:port]) |> Integer.parse() |> elem(0)
  def get_own_id, do: Agent.get(__MODULE__, & &1[:own_id])
end
