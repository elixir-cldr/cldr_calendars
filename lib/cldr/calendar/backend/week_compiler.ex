defmodule Cldr.Calendar.Compiler.Week do
  @moduledoc false

  defmacro __before_compile__(env) do
    config =
      Module.get_attribute(env.module, :options)
      |> Keyword.put(:calendar, env.module)
      |> Cldr.Calendar.extract_options()
      |> Cldr.Calendar.validate_config!(:week)

    Module.put_attribute(env.module, :calendar_config, config)

    quote location: :keep do
      @behaviour Calendar
      @behaviour Cldr.Calendar

      alias Cldr.Calendar.Base.Week

      def __config__ do
        @calendar_config
      end

      def valid_date?(year, week, day) do
        Week.valid_date?(year, week, day, __config__())
      end

      def year_of_era(year) do
        Week.year_of_era(year, __config__())
      end

      def quarter_of_year(year, week, day) do
        Week.quarter_of_year(year, week, day, __config__())
      end

      def month_of_year(year, week, day) do
        Week.month_of_year(year, week, day, __config__())
      end

      def week_of_year(year, week, day) do
        Week.week_of_year(year, week, day, __config__())
      end

      def iso_week_of_year(year, week, day) do
        Week.iso_week_of_year(year, week, day, __config__())
      end

      def day_of_era(year, week, day) do
        Week.day_of_era(year, week, day, __config__())
      end

      def day_of_year(year, week, day) do
        Week.day_of_year(year, week, day, __config__())
      end

      def day_of_week(year, week, day) do
        Week.day_of_week(year, week, day, __config__())
      end

      def weeks_in_year(year) do
        Week.weeks_in_year(year, __config__())
      end

      def days_in_month(year, month) do
        Week.days_in_month(year, month, __config__())
      end

      def year(year) do
        Week.year(year, __config__())
      end

      def quarter(year, quarter) do
        Week.quarter(year, quarter, __config__())
      end

      def month(year, month) do
        Week.month(year, month, __config__())
      end

      def week(year, week) do
        Week.week(year, week, __config__())
      end

      def leap_year?(year) do
        Week.long_year?(year, __config__())
      end

      def first_gregorian_day_of_year(year) do
        Week.first_gregorian_day_of_year(year, __config__())
      end

      def last_gregorian_day_of_year(year) do
        Week.last_gregorian_day_of_year(year, __config__())
      end

      def naive_datetime_to_iso_days(year, week, day, hour, minute, second, microsecond) do
        Week.naive_datetime_to_iso_days(
          year,
          week,
          day,
          hour,
          minute,
          second,
          microsecond,
          __config__()
        )
      end

      def naive_datetime_from_iso_days({days, day_fraction}) do
        Week.naive_datetime_from_iso_days({days, day_fraction}, __config__())
      end

      defdelegate date_to_string(year, week, day), to: Week

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
                  to: Week

      defdelegate day_rollover_relative_to_midnight_utc, to: Calendar.ISO
      defdelegate months_in_year(year), to: Calendar.ISO

      defdelegate naive_datetime_to_string(year, month, day, hour, minute, second, microsecond),
        to: Calendar.ISO

      defdelegate time_from_day_fraction(day_fraction), to: Calendar.ISO
      defdelegate time_to_day_fraction(hour, minute, second, microsecond), to: Calendar.ISO
      defdelegate time_to_string(hour, minute, second, microsecond), to: Calendar.ISO
      defdelegate valid_time?(hour, minute, second, microsecond), to: Calendar.ISO
    end
  end
end
