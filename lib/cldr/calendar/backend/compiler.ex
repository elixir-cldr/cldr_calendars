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
      |> Cldr.Calendar.Gregorian.extract_options()

    Module.put_attribute(env.module, :calendar_config, config)

    quote location: :keep do
      @behaviour Calendar
      @behaviour Cldr.Calendar

      def __config__ do
        @calendar_config
      end

      def valid_date?(year, week, day) do
        Cldr.Calendar.Week.valid_date?(year, week, day, @calendar_config)
      end

      def day_of_era(year, week, day) do
        Cldr.Calendar.Week.day_of_era(year, week, day, @calendar_config)
      end

      def day_of_year(year, week, day) do
        Cldr.Calendar.Week.day_of_year(year, week, day, @calendar_config)
      end

      def month_of_year(year, week, day) do
        Cldr.Calendar.Week.month_of_year(year, week, day, @calendar_config)
      end

      def day_of_week(year, week, day) do
        Cldr.Calendar.Week.day_of_week(year, week, day, @calendar_config)
      end

      def days_in_month(year, month) do
        Cldr.Calendar.Week.days_in_month(year, month, @calendar_config)
      end

      def leap_year?(year) do
        Cldr.Calendar.Week.leap_year?(year, @calendar_config)
      end

      def naive_datetime_to_iso_days(year, week, day, hour, minute, second, microsecond) do
        Cldr.Calendar.Week.naive_datetime_to_iso_days(
          year,
          week,
          day,
          hour,
          minute,
          second,
          microsecond,
          @calendar_config
        )
      end

      def naive_datetime_from_iso_days({days, day_fraction}) do
        Cldr.Calendar.Week.naive_datetime_from_iso_days({days, day_fraction}, @calendar_config)
      end

      defdelegate date_to_string(year, week, day), to: Cldr.Calendar.Week

      defdelegate datetime_to_string(
                    year,
                    month,
                    day,
                    hour,
                    minute,
                    second,
                    microsecond,
                    time_zone,
                    zone_abbr,
                    utc_offset,
                    std_offset
                  ),
                  to: Cldr.Calendar.Week

      defdelegate quarter_of_year(year, week, day), to: Cldr.Calendar.Week
      defdelegate week_of_year(year, week, day), to: Cldr.Calendar.Week

      defdelegate day_rollover_relative_to_midnight_utc, to: Calendar.ISO
      defdelegate months_in_year(year), to: Calendar.ISO

      defdelegate naive_datetime_to_string(year, month, day, hour, minute, second, microsecond),
        to: Calendar.ISO

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
