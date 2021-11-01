defmodule Cldr.Calendar.Compiler.Week do
  @moduledoc false

  defmacro __before_compile__(env) do
    config =
      Module.get_attribute(env.module, :options)
      |> Keyword.put(:calendar, env.module)
      |> Cldr.Calendar.Config.extract_options()
      |> Cldr.Calendar.Config.validate_config!(:week)

    Module.put_attribute(env.module, :calendar_config, config)

    quote location: :keep do
      @behaviour Calendar
      @behaviour Cldr.Calendar

      @type year :: -9999..9999
      @type month :: 1..12
      @type week :: 1..53
      @type day :: 1..7

      import Cldr.Macros
      alias Cldr.Calendar.Base.Week

      def __config__ do
        @calendar_config
      end

      @doc """
      Identifies that the calendar is week based.
      """
      @impl true
      def calendar_base do
        :week
      end

      @doc """
      Defines the CLDR calendar type for this calendar.

      This type is used in support of `Cldr.Calendar.localize/3`.
      Currently only `:gregorian` is supported.

      """
      @impl true
      def cldr_calendar_type do
        :gregorian
      end

      @doc """
      Determines if the date given is valid according to the this calendar.

      """
      @impl true
      def valid_date?(year, week, day) do
        Week.valid_date?(year, week, day, __config__())
      end

      @doc """
      Calculates the year and era from the given `year`.
      The ISO calendar has two eras: the current era which
      starts in year 1 and is defined as era "1". And a
      second era for those years less than 1 defined as
      era "0".

      """
      @spec year_of_era(year) :: {year, era :: non_neg_integer}
      unless Code.ensure_loaded?(Calendar.ISO) && function_exported?(Calendar.ISO, :year_of_era, 3) do
        @impl true
      end

      def year_of_era(year) do
        Week.year_of_era(year, __config__())
      end

      @doc """
      Calculates the year and era from the given `year`,
      `month` and `day`.

      The ISO calendar has two eras: the current era which
      starts in year 1 and is defined as era "1". And a
      second era for those years less than 1 defined as
      era "0".

      """
      @spec year_of_era(year, month, day) :: {year, era :: non_neg_integer}
      @impl true

      def year_of_era(year, _week, _day) do
        Week.year_of_era(year, __config__())
      end

      @doc """
      Returns the calendar year as displayed
      on rendered calendars.

      """
      @spec calendar_year(year, month, day) :: Calendar.year()
      @impl true
      def calendar_year(year, month, day) do
        year
      end

      @doc """
      Returns the related gregorian year as displayed
      on rendered calendars.

      """
      @spec related_gregorian_year(year, month, day) :: Calendar.year()
      @impl true
      def related_gregorian_year(year, month, day) do
        year
      end

      @doc """
      Returns the extended year as displayed
      on rendered calendars.

      """
      @spec extended_year(year, month, day) :: Calendar.year()
      @impl true
      def extended_year(year, month, day) do
        year
      end

      @doc """
      Returns the cyclic year as displayed
      on rendered calendars.

      """
      @spec cyclic_year(year, month, day) :: Calendar.year()
      @impl true
      def cyclic_year(year, month, day) do
        year
      end

      @doc """
      Calculates the quarter of the year from the given `year`, `month`, and `day`.
      It is an integer from 1 to 4.

      """
      @spec quarter_of_year(year, Cldr.Calendar.week(), day) :: 1..4
      @impl true
      def quarter_of_year(year, week, day) do
        Week.quarter_of_year(year, week, day, __config__())
      end

      @doc """
      Calculates the month of the year from the given `year`, `month`, and `day`.
      It is an integer from 1 to 12.

      """
      @spec month_of_year(year, Cldr.Calendar.week(), day) :: month
      @impl true
      def month_of_year(year, week, day) do
        Week.month_of_year(year, week, day, __config__())
      end

      @doc """
      Calculates the week of the year from the given `year`, `month`, and `day`.
      It is an integer from 1 to 53.

      """
      @spec week_of_year(year, Cldr.Calendar.week(), day) :: {year, Cldr.Calendar.week()}
      @impl true
      def week_of_year(year, week, day) do
        Week.week_of_year(year, week, day, __config__())
      end

      @doc """
      Calculates the ISO week of the year from the given `year`, `month`, and `day`.
      It is an integer from 1 to 53.

      """
      @spec iso_week_of_year(year, Cldr.Calendar.week(), day) :: {year, Cldr.Calendar.week()}
      @impl true
      def iso_week_of_year(year, week, day) do
        Week.iso_week_of_year(year, week, day, __config__())
      end

      @doc """
      Calculates the week of the month from the given `year`, `month`, and `day`.
      It is an integer from 1 to 5.

      """
      @spec week_of_month(year, Cldr.Calendar.week(), day) :: {month, Cldr.Calendar.week()}
      @impl true
      def week_of_month(year, week, day) do
        Week.week_of_month(year, week, day, __config__())
      end

      @doc """
      Calculates the day and era from the given `year`, `month`, and `day`.

      """
      @spec day_of_era(year, month, day) :: {day :: pos_integer(), era :: 0..1}
      @impl true
      def day_of_era(year, week, day) do
        Week.day_of_era(year, week, day, __config__())
      end

      @doc """
      Calculates the day of the year from the given `year`, `month`, and `day`.
      It is an integer from 1 to 366.

      """
      @spec day_of_year(year, month, day) :: 1..366
      @impl true
      def day_of_year(year, week, day) do
        Week.day_of_year(year, week, day, __config__())
      end

      @doc """
      Calculates the day of the week from the given `year`, `month`, and `day`.
      It is an integer from 1 to 7, where 1 is Monday and 7 is Sunday.

      """
      if function_exported?(Date, :day_of_week, 2) do
        @spec day_of_week(year, month, day, :default | atom()) ::
            {Calendar.day_of_week(), first_day_of_week :: non_neg_integer(),
              last_day_of_week :: non_neg_integer()}

        @impl true
        def day_of_week(year, month, day, :default) do
          %{day_of_week: first_day} = __config__()
          last_day = Cldr.Math.amod(first_day + days_in_week() - 1, days_in_week())
          day = Week.day_of_week(year, month, day, __config__())
          {day, first_day, last_day}
        end
      else
        @spec day_of_week(year, month, day) :: 1..7
        @impl true
        def day_of_week(year, month, day) do
          Week.day_of_week(year, month, day, __config__())
        end
      end

      @doc """
      Calculates the number of period in a given `year`. A period
      corresponds to a month in month-based calendars and
      a week in week-based calendars..

      """
      @spec periods_in_year(year) :: Calendar.week()
      @impl true
      def periods_in_year(year) do
        weeks_in_year(year)
      end

      @doc """
      Returns the number weeks in a given year.

      """
      @spec weeks_in_year(year) :: Calendar.week()
      @impl true
      def weeks_in_year(year) do
        Week.weeks_in_year(year, __config__())
      end

      @doc """
      Returns the number days in a given year.

      """
      @spec days_in_year(year) :: Calendar.day()
      @impl true
      def days_in_year(year) do
        Week.days_in_year(year, __config__())
      end

      @doc """
      Returns how many days there are in the given year-month.

      """
      @spec days_in_month(year, month) :: Calendar.day()
      @impl true
      def days_in_month(year, month) do
        Week.days_in_month(year, month, __config__())
      end

      @doc """
      Returns the number days in a a week.

      """
      def days_in_week do
        Week.days_in_week()
      end

      @doc """
      Returns a `Date.Range.t` representing
      a given year.

      """
      @impl true
      def year(year) do
        Week.year(year, __config__())
      end

      @doc """
      Returns a `Date.Range.t` representing
      a given quarter of a year.

      """
      @impl true
      def quarter(year, quarter) do
        Week.quarter(year, quarter, __config__())
      end

      @doc """
      Returns a `Date.Range.t` representing
      a given month of a year.

      """
      @impl true
      def month(year, month) do
        Week.month(year, month, __config__())
      end

      @doc """
      Returns a `Date.Range.t` representing
      a given week of a year.

      """
      @impl true
      def week(year, week) do
        Week.week(year, week, __config__())
      end

      @doc """
      Adds an `increment` number of `date_part`s
      to a `year-month-day`.

      `date_part` can be `:years`, `:quarters`,
      or `:months`.

      """
      @impl true
      def plus(year, month, day, date_part, increment, options \\ [])

      def plus(year, month, day, :years, quarters, options) do
        Week.plus(year, month, day, __config__(), :years, quarters, options)
      end

      def plus(year, week, day, :quarters, quarters, options) do
        Week.plus(year, week, day, __config__(), :quarters, quarters, options)
      end

      def plus(year, week, day, :months, months, options) do
        Week.plus(year, week, day, __config__(), :months, months, options)
      end

      @doc """
      Adds a :year, :month, :day or time increments

      These functions support CalendarInterval

      """
      def add(year, month, day, hour, minute, second, microsecond, :year, step) do
        {year, month, day} = plus(year, month, day, :years, step)
        {year, month, day, hour, minute, second, microsecond}
      end

      def add(year, month, day, hour, minute, second, microsecond, :quarter, step) do
        {year, month, day} = plus(year, month, day, :quarters, step)
        {year, month, day, hour, minute, second, microsecond}
      end

      def add(year, month, day, hour, minute, second, microsecond, :month, step) do
        {year, month, day} = plus(year, month, day, :months, step)
        {year, month, day, hour, minute, second, microsecond}
      end

      @doc """
      Returns if the given year is a leap year.

      """
      @spec leap_year?(year) :: boolean()
      @impl true
      def leap_year?(year) do
        Week.long_year?(year, __config__())
      end

      @doc """
      Returns the number of days since the calendar
      epoch for a given `year-month-day`

      """
      def date_to_iso_days(year, week, day) do
        Week.date_to_iso_days(year, week, day, __config__())
      end

      @doc """
      Returns `{year, month, day}` calculated from
      the number of `iso_days`.

      """
      def date_from_iso_days(iso_days) do
        Week.date_from_iso_days(iso_days, __config__())
      end

      @doc """
      Returns the number of `iso_days` that is
      the first day of the given
      year for this calendar.

      """
      def first_gregorian_day_of_year(year) do
        Week.first_gregorian_day_of_year(year, __config__())
      end

      @doc """
      Returns the number of `iso_days` that is
      the last day of the given
      year for this calendar.

      """
      def last_gregorian_day_of_year(year) do
        Week.last_gregorian_day_of_year(year, __config__())
      end

      @doc """
      Returns the `t:Calendar.iso_days/0` format of the specified date.

      """
      @impl true
      @spec naive_datetime_to_iso_days(
              Calendar.year(),
              Calendar.month(),
              Calendar.day(),
              Calendar.hour(),
              Calendar.minute(),
              Calendar.second(),
              Calendar.microsecond()
            ) :: Calendar.iso_days()

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

      @doc """
      Converts the `t:Calendar.iso_days/0` format to the datetime format specified by this calendar.

      """
      @spec naive_datetime_from_iso_days(Calendar.iso_days()) :: {
              Calendar.year(),
              Calendar.month(),
              Calendar.day(),
              Calendar.hour(),
              Calendar.minute(),
              Calendar.second(),
              Calendar.microsecond()
            }
      @impl true
      def naive_datetime_from_iso_days({days, day_fraction}) do
        Week.naive_datetime_from_iso_days({days, day_fraction}, __config__())
      end

      @doc false
      @impl true
      def date_to_string(year, month, day) do
        Week.date_to_string(year, month, day)
      end

      @doc false
      @impl true
      def datetime_to_string(
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
          ) do
        Week.datetime_to_string(
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
        )
      end

      @doc false
      @impl true
      def naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) do
        Week.naive_datetime_to_string(year, month, day, hour, minute, second, microsecond)
      end

      @doc false
      calendar_impl()

      def parse_date(string) do
        Cldr.Calendar.Parse.parse_week_date(string, __MODULE__)
      end

      @doc false
      calendar_impl()

      def parse_utc_datetime(string) do
        Cldr.Calendar.Parse.parse_utc_datetime(string, __MODULE__)
      end

      @doc false
      calendar_impl()

      def parse_naive_datetime(string) do
        Cldr.Calendar.Parse.parse_naive_datetime(string, __MODULE__)
      end

      if Version.match?(System.version(), ">= 1.10.0-dev") do
        @doc false
        defdelegate parse_time(string), to: Calendar.ISO
      end

      @doc false
      defdelegate day_rollover_relative_to_midnight_utc, to: Calendar.ISO

      @doc false
      defdelegate months_in_year(year), to: Calendar.ISO

      @doc false
      defdelegate time_from_day_fraction(day_fraction), to: Calendar.ISO

      @doc false
      defdelegate time_to_day_fraction(hour, minute, second, microsecond), to: Calendar.ISO

      @doc false
      defdelegate time_to_string(hour, minute, second, microsecond), to: Calendar.ISO

      @doc false
      defdelegate valid_time?(hour, minute, second, microsecond), to: Calendar.ISO
    end
  end
end
