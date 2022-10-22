defmodule Handin2.Endpoint do
  require Logger
  use Plug.Router

  alias Handin2.Server

  plug :match
  plug Plug.Parsers, parsers: [:json], pass: ["application/json", "text/json"], json_decoder: Poison
  plug :respond_json
  plug :dispatch

  post "/commit" do
    Server.commit(conn.body_params) |> handle_server_response(conn)
  end

  post "/reveal/:id" do
    Server.reveal(conn.body_params, id) |> handle_server_response(conn)
  end

  match _ do
    send_resp(conn, 404, Poison.encode!(%{message: "Not found", path: "#{inspect(conn.request_path)}"}))
  end

  def generate_response({:ok, msg}), do: {200, msg}
  def generate_response({:error, msg}), do: {400, msg}
  def generate_response(ms), do: {400, %{error: "Unknown error", message: ms}}

  def encode_response({code, msg}), do: {code, msg |> Poison.encode!()}

  def respond_json(conn, _), do: put_resp_content_type(conn, "application/json")

  def send_response({code, response}, conn), do: send_resp(conn, code, response)

  def handle_server_response(server_response, conn) do
    server_response
    |> generate_response()
    |> encode_response()
    |> send_response(conn)
  end
end
