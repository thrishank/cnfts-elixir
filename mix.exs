defmodule Cnft.MixProject do
  use Mix.Project

  def project do
    [
      app: :cnft,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps() 
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
	      {:rustler, "~> 0.36.1", runtime: false},
        {:httpoison, "~> 1.8"},
        {:jason, "~> 1.2"},
        {:base58, "~> 0.1.1"}
    ]
  end
end
