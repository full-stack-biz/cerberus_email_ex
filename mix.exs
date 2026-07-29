defmodule CerberusEmail.MixProject do
  use Mix.Project

  @source_url "https://github.com/full-stack-biz/cerberus_email_ex"

  def project do
    [
      app: :cerberus_email,
      version: "0.1.0",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      source_url: @source_url,
      deps: deps(),
      package: package(),
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:ex_unit]]
    ]
  end

  def cli do
    [preferred_envs: [ci: :test]]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 1.1"},
      {:vibe_kit, "~> 0.1"},
      {:ex_slop, "~> 0.4", only: [:dev, :test], runtime: false},
      {:reach, "~> 2.0", only: [:dev, :test], runtime: false},
      {:ex_dna, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      description: "Cross-client-tested responsive email components for Phoenix",
      links: %{"GitHub" => @source_url}
    ]
  end

  defp aliases do
    [
      ci: [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "test",
        "credo --strict",
        "dialyzer",
        "ex_dna --max-clones 0",
        "reach.check --arch --smells"
      ]
    ]
  end
end
