defmodule Handin2.MixProject do
  use Mix.Project

  def project do
    [
      app: :handin2,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Handin2.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 5.0"},
      {:httpoison, "~> 1.8"},
      {:type_check, "~> 0.12.1"},
      {:hackney, github: "benoitc/hackney", override: true,  ref: "27bbf8ec11033e28c7b8424759851d2d9bafa887"}
    ]
  end
end
