defmodule Cldr.Calendar.Compiler.Month do
  @moduledoc false

  defmacro __before_compile__(env) do
    config =
      Module.get_attribute(env.module, :options)
      |> Keyword.put(:calendar, env.module)
      |> Cldr.Calendar.extract_options()
      |> Cldr.Calendar.validate_config!(:month)

    Module.put_attribute(env.module, :calendar_config, config)

    quote location: :keep do
      @behaviour Calendar
      @behaviour Cldr.Calendar

      alias Cldr.Calendar.Base.Month

      def __config__ do
        @calendar_config
      end

      def valid_date?(year, month, day) do
        Month.valid_date?(year, month, day, __config__())
      end

      def year_of_era(year) do
        Month.year_of_era(year, __config__())
      end

      def quarter_of_year(year, month, day) do
        Month.quarter_of_year(year, month, day, __config__())
      end

      def month_of_year(year, month, day) do
        Month.month_of_year(year, month, day, __config__())
      end

      def week_of_year(year, month, day) do
        Month.week_of_year(year, month, day, __config__())
      end

      def iso_week_of_year(year, month, day) do
        Month.iso_week_of_year(year, month, day)
      end

      def day_of_era(year, month, day) do
        Month.day_of_era(year, month, day, __config__())
      end

      def day_of_year(year, month, day) do
        Month.day_of_year(year, month, day, __config__())
      end

      def day_of_week(year, month, day) do
        Month.day_of_week(year, month, day, __config__())
      end

      def days_in_month(year, month) do
        Month.days_in_month(year, month, __config__())
      end

      def year(year) do
        Month.year(year, __config__())
      end

      def quarter(year, quarter) do
        Month.quarter(year, quarter, __config__())
      end

      def month(year, month) do
        Month.month(year, month, __config__())
      end

      def week(year, week) do
        Month.week(year, week, __config__())
      end

      def leap_year?(year) do
        Month.leap_year?(year, __config__())
      end

      def first_gregorian_day_of_year(year) do
        Month.first_gregorian_day_of_year(year, __config__())
      end

      def last_gregorian_day_of_year(year) do
        Month.last_gregorian_day_of_year(year, __config__())
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
          __config__()
        )
      end

      def naive_datetime_from_iso_days({days, day_fraction}) do
        Month.naive_datetime_from_iso_days({days, day_fraction}, __config__())
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
    end
  end

  def validate_config!(config) do
    config
  end
end
