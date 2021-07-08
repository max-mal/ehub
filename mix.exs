defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :fs],
      env: [
        web: true,
        watch_recompiler: true,
      ],
      mod: {App.Application, []},
      # applications: [:guardian]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.5"},
      {:fs, github: "synrc/fs"},
      {:jason, "~> 1.2"},
      {:ecto_sql, "~> 3.0"},
      {:myxql, "~> 0.5.1"},
      {:bcrypt_elixir, "~> 2.3"},
      {:guardian, "~> 2.0"},
      {:phoenix_html, "~> 2.14"}
    ]
  end
end
