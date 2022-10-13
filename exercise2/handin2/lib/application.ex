defmodule Handin2.Application do
  @moduledoc false

  use Application

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
      certfile: "priv/cert/selfsigned.pem",
      keyfile: "priv/cert/selfsigned_key.pem",
      otp_app: :handin2,
    ]
  end
end
