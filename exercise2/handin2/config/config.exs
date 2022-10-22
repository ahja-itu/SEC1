import Config


default_player_name = fn ->
  ["alice", "bob"] |> Enum.random()
end

localhost = "localhost:4040"

config :handin2,
  player_names: (System.get_env("PLAYERS") || localhost)  |> String.split(","),
  player_name: (System.get_env("PLAYER") || default_player_name.()),
  is_playing: System.get_env("IS_PLAYING") != nil && System.get_env("IS_PLAYING") != "true"


config :logger, :console,
  format: "$time [$level] [$metadata] $message\n",
  metadata: [:player, :opponent]
