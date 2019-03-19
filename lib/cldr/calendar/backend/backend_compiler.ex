defmodule Cldr.Calendar.Backend.Compiler do
  def define_calendar_modules(config) do
    quote location: :keep do
      unquote(Cldr.Calendar.Backend.define_calendar_module(config))
    end
  end
end
