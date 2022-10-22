defmodule Handin2.Application do
  @moduledoc false

  use Application

  alias Handin2.Security

  @impl true
  def start(_type, _args) do
    children = [
      {Handin2.Server, name: Handin2.Server},
      {Handin2.Client, name: Handin2.Client},
      {Plug.Cowboy, scheme: :https, plug: Handin2.Endpoint, options: endpoint_opts()},
    ]

    opts = [strategy: :one_for_one, name: Handin2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def endpoint_opts do
    [
      port: 4040,
      cacertfile: Security.config(:cacert),
      certfile: Security.config(:cert),
      keyfile: Security.config(:privatekey),
      otp_app: :handin2,
    ]
  end
end
