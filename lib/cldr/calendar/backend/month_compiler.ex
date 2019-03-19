defmodule Cldr.Calendar.Compiler.Month do
  @moduledoc false

  defmacro __before_compile__(env) do
    config =
      Module.get_attribute(env.module, :options)
      |> Keyword.put(:calendar, env.module)
      |> validate_config
      |> Cldr.Calendar.extract_options()

    Module.put_attribute(env.module, :calendar_config, config)

    quote location: :keep do
      @behaviour Calendar
      @behaviour Cldr.Calendar

      alias Cldr.Calendar.Base.Month

      def __config__ do
        @calendar_config
      end

      def valid_date?(year, month, day) do
        Month.valid_date?(year, month, day, @calendar_config)
      end

      def quarter_of_year(year, month, day) do
        Month.quarter_of_year(year, month, day, @calendar_config)
      end

      def month_of_year(year, month, day) do
        Month.month_of_year(year, month, day, @calendar_config)
      end

      def week_of_year(year, month, day) do
        Month.week_of_year(year, month, day, @calendar_config)
      end

      def iso_week_of_year(year, month, day) do
        Month.iso_week_of_year(year, month, day)
      end

      def day_of_era(year, month, day) do
        Month.day_of_era(year, month, day, @calendar_config)
      end

      def day_of_year(year, month, day) do
        Month.day_of_year(year, month, day, @calendar_config)
      end

      def day_of_week(year, month, day) do
        Month.day_of_week(year, month, day, @calendar_config)
      end

      def days_in_month(year, month) do
        Month.days_in_month(year, month, @calendar_config)
      end

      def leap_year?(year) do
        Month.leap_year?(year, @calendar_config)
      end

      def first_day_of_year(year) do
        Month.first_day_of_year(year, @calendar_config)
      end

      def last_day_of_year(year) do
        Month.last_day_of_year(year, @calendar_config)
      end

      def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond) do
        Month.naive_datetime_to_iso_days(
          year,
          month,
          day,
          hour,
          minute,
          second,
          microsecond,
          @calendar_config
        )
      end

      def naive_datetime_from_iso_days({days, day_fraction}) do
        Month.naive_datetime_from_iso_days({days, day_fraction}, @calendar_config)
      end

      defimpl String.Chars do
        def to_string(%{calendar: calendar, year: year, month: month, day: day}) do
          calendar.date_to_string(year, month, day)
        end
      end

      defdelegate date_to_string(year, month, day), to: Calendar.ISO

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
                  to: Calendar.ISO

      defdelegate naive_datetime_to_string(year, month, day, hour, minute, second, microsecond),
        to: Calendar.ISO

      defdelegate day_rollover_relative_to_midnight_utc, to: Calendar.ISO
      defdelegate months_in_year(year), to: Calendar.ISO
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
