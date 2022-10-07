defmodule Actor.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Task.Supervisor, name: Networking.TaskSupervisor},
      {Networking.Settings, name: Networking.Settings},
      {Task, fn -> Networking.listen() end}
    ]

    opts = [strategy: :one_for_one, name: Actor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
