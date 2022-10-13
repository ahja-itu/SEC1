import Config


random_player_name = fn ->
  :crypto.strong_rand_bytes(8) |> Base.encode16() |> String.slice(0, 7)
end

localhost = "localhost:4040"

config :handin2,
  player_names: (System.get_env("PLAYERS") || localhost)  |> String.split(","),
  player_name: (System.get_env("PLAYER") || random_player_name.())

config :logger, :console,
  format: "$time [$level] [$metadata] $message\n",
  metadata: [:player, :opponent]
