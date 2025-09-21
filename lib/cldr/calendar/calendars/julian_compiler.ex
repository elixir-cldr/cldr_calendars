defmodule Cldr.Calendar.Julian.Compiler do

  defmacro __before_compile__(env) do
    opts =
      Module.get_attribute(env.module, :options)
      |> Keyword.put(:calendar, env.module)
      |> Macro.escape()

    quote bind_quoted: [opts: opts] do
      @behaviour Calendar
      @behaviour Cldr.Calendar

      {start_month, start_day} = Keyword.get(opts, :new_year_starting_month_and_day, {1, 1})

      @new_year_starting_month start_month
      @new_year_starting_day start_day

      @quarters_in_year 4
      @months_in_year Cldr.Calendar.Julian.months_in_year(0)
      @last_month_of_year rem(start_month + (@months_in_year - 1), @months_in_year)

      defguard year_rollover(month, day) when month <= @new_year_starting_month and day < @new_year_starting_day

      # Adjust the year to be a Jan 1st starting year and carry
      # on
      def date_to_iso_days(year, month, day) when year_rollover(month, day) do
        Cldr.Calendar.Julian.date_to_iso_days(year + 1, month, day)
      end

      def date_to_iso_days(year, month, day) do
        Cldr.Calendar.Julian.date_to_iso_days(year, month, day)
      end

      def naive_datetime_to_iso_days(year, month, day, 0, 0, 0, {0, 0}) do
        {date_to_iso_days(year, month, day), {0, 0}}
      end

      # Adjust the year to be this calendars starting year
      def date_from_iso_days(iso_days) do
        {year, month, day} = Cldr.Calendar.Julian.date_from_iso_days(iso_days)

        if month <= @new_year_starting_month and day < @new_year_starting_day do
          {year + 1, month, day}
        else
          {year, month, day}
        end
      end

      def days_in_year(year) do
        first_day = date_to_iso_days(year, @new_year_starting_month, @new_year_starting_day)
        first_day_next_year = date_to_iso_days(year + 1, @new_year_starting_month, @new_year_starting_day)
        first_day_next_year - first_day
      end

      # Here we use month to mean ordinal month. Therefore if the calendar
      # starts on March 25th, then days in month for March will be seen as
      # days if month for month 1.

      def days_in_month(month) do
        {:error, :unresolved}
      end

      def days_in_month(year, ordinal_month) do
        adjusted_month =
          Cldr.Math.amod(ordinal_month + @new_year_starting_month - 1, @months_in_year)

        adjusted_year =
          if adjusted_month < @new_year_starting_month, do: year + 1, else: year

        cond do
          # The first month of the year will be short since the year starts
          # part way through the month
          adjusted_month == @new_year_starting_month ->
            days_in_julian_month = Cldr.Calendar.Julian.days_in_month(year, ordinal_month)
            days_in_julian_month - @new_year_starting_day

          # The last month of the year will be "long" since the first part of the
          # first month that is before the start of year will be included
          adjusted_month == @last_month_of_year ->
            start_of_month =
              date_to_iso_days(adjusted_year, adjusted_month, 1)
            start_of_next_month =
              date_to_iso_days(adjusted_year, @new_year_starting_month, @new_year_starting_day)
            start_of_next_month - start_of_month

          true ->
            Cldr.Calendar.Julian.days_in_month(year, adjusted_month)
        end
      end

      def year(year) do
        first_day = date_to_iso_days(year, @new_year_starting_month, @new_year_starting_day)
        {:ok, first_date} = Date.new(year, @new_year_starting_month, @new_year_starting_day, __MODULE__)

        last_day = date_to_iso_days(year, @new_year_starting_month, @new_year_starting_day) - 1
        {year, month, day} = date_from_iso_days(last_day)
        {:ok, last_date} = Date.new(year, month, day, __MODULE__)

        Date.range(first_date, last_date, 1)
      end

      def quarter(year, quarter) do

      end

      def month(year, ordinal_month) do
        adjusted_month =
          Cldr.Math.amod(ordinal_month + @new_year_starting_month - 1, @months_in_year)

        adjusted_year =
          if adjusted_month < @new_year_starting_month, do: year + 1, else: year

        first_day =
          if adjusted_month == @new_year_starting_month, do: @new_year_starting_day, else: 1

        {:ok, first} = Date.new(adjusted_year, adjusted_month, first_day, __MODULE__)
        first_iso_days = date_to_iso_days(year, adjusted_month, first_day)
        days_in_month = days_in_month(year, ordinal_month)

        last_iso_days = first_iso_days + days_in_month - 1
        {year, month, day} = date_from_iso_days(last_iso_days)
        {:ok, last} = Date.new(year, month, day, __MODULE__)

        Date.range(first, last, 1)
      end

      def quarter_of_year(year, month, day) do
        month_of_year = month_of_year(year, month, day)

        ceil(month_of_year / (@months_in_year / @quarters_in_year))
      end

      # Returns the ordinal month accounting for a long month 12
      def month_of_year(_year, month, day)
          when month == @new_year_starting_month and day < @new_year_starting_day do
        @months_in_year
      end

      def month_of_year(_year, month, _day) do
        Cldr.Math.amod(month - @new_year_starting_month + 1, @months_in_year)
      end

      def day_of_year(year, month, day) do
        adjusted_year =
          if month < @new_year_starting_month, do: year + 1, else: year

        first_day = date_to_iso_days(year, @new_year_starting_month, @new_year_starting_day)
        this_day = date_to_iso_days(adjusted_year, month, day)
        this_day - first_day + 1
      end

      def calendar_year(year, month, day) when year_rollover(month, day) do
        year - 1
      end

      def calendar_year(year, _month, _day) do
        year
      end

      def related_gregorian_year(year, month, day) do
        iso_days = date_to_iso_days(year, month, day)
        {year, _month, _day} = Cldr.Calendar.Gregorian.date_from_iso_days(iso_days)
        year
      end

      def extended_year(year, month, day) when year_rollover(month, day) do
        year - 1
      end

      def extended_year(year, month, day) when year_rollover(month, day) do
        year
      end

      def cyclic_year(year, month, day) do
        calendar_year(year, month, day)
      end

      defdelegate valid_date?(year, month, day), to: Cldr.Calendar.Julian
      defdelegate leap_year?(year), to: Cldr.Calendar.Julian
      defdelegate plus(year, month, day, part, years, options), to: Cldr.Calendar.Julian
      defdelegate week(year, week), to: Cldr.Calendar.Julian
      defdelegate weeks_in_year(year), to: Cldr.Calendar.Julian
      defdelegate months_in_year(year), to: Cldr.Calendar.Julian
      defdelegate periods_in_year(year), to: Cldr.Calendar.Julian
      defdelegate day_of_week(year, month, day, starts_on), to: Cldr.Calendar.Julian
      defdelegate day_of_era(year, month, day), to: Cldr.Calendar.Julian
      defdelegate iso_week_of_year(year, month, day), to: Cldr.Calendar.Julian
      defdelegate week_of_year(year, month, day), to: Cldr.Calendar.Julian
      defdelegate year_of_era(year, month, day), to: Cldr.Calendar.Julian
      defdelegate parse_date(date), to: Cldr.Calendar.Julian
      defdelegate date_to_string(year, month, day), to: Cldr.Calendar.Julian
      defdelegate cldr_calendar_type(), to: Cldr.Calendar.Julian
      defdelegate calendar_base(), to: Cldr.Calendar.Julian
      defdelegate week_of_month(year, month, day), to: Cldr.Calendar.Julian
      defdelegate valid_time?(hour, minute, second, millisecond), to: Cldr.Calendar.Julian
      defdelegate time_to_string(hour, minute, second, millisecond), to: Cldr.Calendar.Julian
      defdelegate time_to_day_fraction(hour, minute, second, millisecond), to: Cldr.Calendar.Julian
      defdelegate time_from_day_fraction(fraction), to: Cldr.Calendar.Julian
      defdelegate shift_time(hour, minute, second, millisecond, duration), to: Cldr.Calendar.Julian
      defdelegate shift_date(year, month, day, duration), to: Cldr.Calendar.Julian
      defdelegate shift_naive_datetime(year, month, day, hour, minute, second, millisecond, duration), to: Cldr.Calendar.Julian
      defdelegate iso_days_to_end_of_day(iso_days), to: Cldr.Calendar.Julian
      defdelegate iso_days_to_beginning_of_day(iso_days), to: Cldr.Calendar.Julian
      defdelegate naive_datetime_from_iso_days(iso_days), to: Cldr.Calendar.Julian
      defdelegate parse_utc_datetime(string), to: Cldr.Calendar.Julian
      defdelegate parse_time(string), to: Cldr.Calendar.Julian
      defdelegate parse_naive_datetime(string), to: Cldr.Calendar.Julian
      defdelegate day_rollover_relative_to_midnight_utc, to: Cldr.Calendar.Julian

      defdelegate datetime_to_string(year, month, day, hour, minute, second, microsecond, time_zone, zone_abbr, utc_offset, std_offset),
        to: Cldr.Calendar.Julian

      defdelegate datetime_to_string(year, month, day, hour, minute, second, microsecond, time_zone, zone_abbr, utc_offset, std_offset, format),
        to: Cldr.Calendar.Julian

      defdelegate naive_datetime_to_string(year, month, day, hour, minute, second, microsecond),
        to: Cldr.Calendar.Julian

    end
  end
end