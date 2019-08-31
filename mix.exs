defmodule Cldr.Calendar.MixProject do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :ex_cldr_calendars,
      version: @version,
      elixir: "~> 1.8",
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Cldr Calendars",
      source_url: "https://github.com/elixir-cldr/cldr_calendars",
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore_warnings",
        plt_add_apps: ~w(inets jason mix)a
      ],
      compilers: Mix.compilers()
    ]
  end

  defp description do
    """
    Localized month- and week-based calendars and calendar functions
    based upon CLDR data.
    """
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: links(),
      files: [
        "lib",
        "config",
        "mix.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*",
        "priv/fiscal_years_by_territory.csv"
      ]
    ]
  end

  defp deps do
    [
      {:ex_cldr, "~> 2.8"},
      {:ex_cldr_units, "~> 2.0", optional: true},
      {:ex_cldr_lists, "~> 2.4", optional: true},
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.18", only: [:release, :dev]},
      {:benchee, "~> 0.14", optional: true, only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/elixir-cldr/cldr_calendars",
      "Readme" => "https://github.com/elixir-cldr/cldr_calendars/blob/v#{@version}/README.md",
      "Changelog" =>
        "https://github.com/elixir-cldr/cldr_calendars/blob/v#{@version}/CHANGELOG.md"
    }
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      logo: "logo.png",
      extras: [
        "README.md",
        "LICENSE.md",
        "CHANGELOG.md"
      ],
      skip_undefined_reference_warnings_on: ["changelog"]
    ]
  end

  def aliases do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "mix", "test"]
  defp elixirc_paths(:dev), do: ["lib", "mix", "bench"]
  defp elixirc_paths(_), do: ["lib"]
end
