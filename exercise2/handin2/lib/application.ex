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
      verify: :verify_peer,
      verify_fun: &verify_fun_selfsigned_cert/3,
    ]
  end


  defp verify_fun_selfsigned_cert(_, {:bad_cert, :selfsigned_peer}, user_state),
  do: {:valid, user_state}

  defp verify_fun_selfsigned_cert(_, {:bad_cert, _} = reason, _),
    do: {:fail, reason}

  defp verify_fun_selfsigned_cert(_, {:extension, _}, user_state),
    do: {:unkown, user_state}

  defp verify_fun_selfsigned_cert(_, :valid, user_state),
    do: {:valid, user_state}

  defp verify_fun_selfsigned_cert(_, :valid_peer, user_state),
    do: {:valid, user_state}
end
