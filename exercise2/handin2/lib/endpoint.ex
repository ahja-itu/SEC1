defmodule Handin2.Endpoint do
  use Plug.Router
  require Logger

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :my_app
  end

  plug :match
  plug Plug.Parsers, parsers: [:json], pass: ["application/json", "text/json"], json_decoder: Poison
  plug :respond_json
  plug :dispatch

  def generate_response({:ok, msg}), do: {200, msg}
  def generate_response({:error, msg}), do: {400, msg}
  def generate_response(ms), do: {400, %{error: "Unknown error", message: ms}}

  def encode_response({code, msg}), do: {code, msg |> Poison.encode!()}

  def respond_json(conn, _), do: put_resp_content_type(conn, "application/json")

  # This only works if you make POST requests with the body in JSON format
  match _ do
    conn
    |> Handin2.Server.send_msg()
    |> generate_response()
    |> encode_response()
    |> then(fn {code, response} -> send_resp(conn, code, response) end)
  end

end
