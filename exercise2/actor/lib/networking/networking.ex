defmodule Networking do
  require Logger
  @moduledoc """
  Contains the code to handle the networking. This means accepting TCP
  connections and starting tasks to handle it with an instance of the
  Actor GenServer.
  """

  def listen do
    port = Networking.Settings.get_port()

    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("#{Networking.Settings.get_own_id} connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Networking.TaskSupervisor, fn ->
      {:ok, actor_pid} = Actor.start_link()
      serve(actor_pid, client)
    end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(actor, socket) do
    socket
    |> read_line()
    |> String.trim()
    |> then(&GenServer.call(actor, {:msg, &1}))

    serve(actor, socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  # defp write_line(line, socket) do
  #   :gen_tcp.send(socket, line)
  # end
end
