defmodule Cnft.MixProject do
  use Mix.Project

  def project do
    [
      app: :cnft,
      version: "0.1.1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: "An Elixir project to mint and transfer Solana CNFTs",
      name: "cnft",
      source_url: "https://github.com/thrishank/cnfts-elixir",
      deps: deps(),
      package: package()  # Add this line to reference the package/0 function
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:rustler, "~> 0.36.1", runtime: false},
      {:mox, "~> 1.1", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],  # Replace with your actual license
      links: %{"GitHub" => "https://github.com/thrishank/cnfts-elixir"},
      maintainers: ["Thrishank"],  
      files: ~w(lib native priv .formatter.exs mix.exs README.md)
    ]
  end
end
