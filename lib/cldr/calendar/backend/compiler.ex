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

    quote location: :keep do
      @behaviour Calendar

      def __config__ do
        unquote(Macro.escape(config))
      end

      defdelegate valid_date?(year, week, day), to: Cldr.Calendar.Week
      defdelegate date_to_string(year, week, day), to: Cldr.Calendar.Week

      defdelegate day_rollover_relative_to_midnight_utc, to: Calendar.ISO
      defdelegate months_in_year(year), to: Calendar.ISO
      defdelegate naive_datetime_to_string(year, month, day, hour, minute, second, microsecond), to: Calendar. ISO
      defdelegate time_from_day_fraction(day_fraction), to: Calendar.ISO
      defdelegate time_to_day_fraction(hour, minute, second, microsecond), to: Calendar.ISO
      defdelegate time_to_string(hour, minute, second, microsecond), to: Calendar.ISO
      defdelegate valid_time?(hour, minute, second, microsecond), to: Calendar.ISO
      defdelegate year_of_era(year), to: Calendar.ISO
    end
  end

  def validate_config(config) do
    config
  end

end