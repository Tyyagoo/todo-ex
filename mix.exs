defmodule TodoEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :todo_ex,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [release: :prod]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {TodoEx.Application, []}
    ]
  end

  defp deps do
    [
      {:poolboy, "~> 1.5"},
      {:plug_cowboy, "~> 1.0"},
      {:plug, "~> 1.4"},
      {:distillery, "~> 2.1"}
    ]
  end
end
