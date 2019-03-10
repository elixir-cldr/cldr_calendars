defmodule Cldr.Calendar.Backend.Compiler do
  @moduledoc false

  def define_calendar_modules(config) do
    quote location: :keep do
      unquote(Cldr.Calendar.Backend.define_calendar_module(config))
    end
  end

  defmacro __before_compile__(env) do
    config =
      Module.get_attribute(env.module, :options)
      |> Keyword.put(:calendar, env.module)
      |> validate_config
      |> Cldr.Calendar.Gregorian.extract_options

    Module.put_attribute(env.module, :calendar_config, config)

    quote location: :keep do

    end
  end

  def validate_config(config) do
    config
  end

end