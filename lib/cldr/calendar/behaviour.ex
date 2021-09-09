defmodule Cldr.Calendar.Behaviour do
  defmacro __using__(opts \\ []) do
    days_in_week = Keyword.get(opts, :days_in_week, 7)
    epoch = Keyword.fetch!(opts, :epoch)

    {date, []} = Code.eval_quoted(epoch)
    epoch = Date.to_gregorian_days(date)
    epoch_day_of_week = Date.day_of_week(date)

    cldr_calendar_type = Keyword.get(opts, :cldr_calendar_type, :gregorian)
    cldr_calendar_base = Keyword.get(opts, :cldr_calendar_base, :month)

    quote do
      import Cldr.Macros

      @behaviour Calendar
      @behaviour Cldr.Calendar

      @type year :: -9999..9999
      @type month :: 1..13
      @type day :: 1..30

      @days_in_week unquote(days_in_week)
      @epoch unquote(epoch)
      @epoch_day_of_week unquote(epoch_day_of_week)

      def epoch do
        @epoch
      end

      @doc """
      Defines the CLDR calendar type for this calendar.

      This type is used in support of `Cldr.Calendar.
      localize/3`.

      """
      @impl true
      def cldr_calendar_type do
        unquote(cldr_calendar_type)
      end

      @doc """
      Identifies that this calendar is month based.
      """
      @impl true
      def calendar_base do
        unquote(cldr_calendar_base)
      end

      @doc """
      Determines if the date given is valid according to
      this calendar.

      """
      @impl true
      def valid_date?(year, month, day) do
        month <= months_in_year(year) && day <= days_in_month(year, month)
      end

      @doc """
      Calculates the year and era from the given `year`.

      """
      @spec year_of_era(year) :: {year, era :: 0..1}
      @impl true

      def year_of_era(year) when year >= 0 do
        {year, 1}
      end

      def year_of_era(year) when year < 0 do
        {abs(year), 0}
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
      Returns the related gregorain year as displayed
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
      Calculates the quarter of the year from the given
      `year`, `month`, and `day`.

      By default this function always returns
      `{:error, :not_defined}`.

      """
      @spec quarter_of_year(year, month, day) :: 1..4
      @impl true

      def quarter_of_year(_year, _month, _day) do
        {:error, :not_defined}
      end

      @doc """
      Calculates the month of the year from the given
      `year`, `month`, and `day`.

      It returns integer from 1 to 12 for a
      normal year and 1 to 13 for a leap year.

      """
      @spec month_of_year(year, month, day) :: month
      @impl true

      def month_of_year(_year, month, _day) do
        month
      end

      @doc """
      Calculates the week of the year from the given
      `year`, `month`, and `day`.

      By default this function always returns
      `{:error, :not_defined}`.

      """
      @spec week_of_year(year, month, day) :: {:error, :not_defined}
      @impl true

      def week_of_year(_year, _month, _day) do
        {:error, :not_defined}
      end

      @doc """
      Calculates the ISO week of the year from the
      given `year`, `month`, and `day`.

      By default this function always returns
      `{:error, :not_defined}`.

      """
      @spec iso_week_of_year(year, month, day) :: {:error, :not_defined}
      @impl true

      def iso_week_of_year(_year, _month, _day) do
        {:error, :not_defined}
      end

      @doc """
      Calculates the week of the year from the given
      `year`, `month`, and `day`.

      By default this function always returns
      `{:error, :not_defined}`.

      """
      @spec week_of_month(year, month, day) :: {pos_integer(), pos_integer()} | {:error, :not_defined}
      @impl true

      def week_of_month(_year, _month, _day) do
        {:error, :not_defined}
      end

      @doc """
      Calculates the day and era from the given
      `year`, `month`, and `day`.

      By default we consider on two eras: before the epoch
      and on-or-after the epoch.

      """
      @spec day_of_era(year, month, day) :: {day :: pos_integer(), era :: 0..1}
      @impl true

      def day_of_era(year, month, day) do
        {_, era} = year_of_era(year)
        days = date_to_iso_days(year, month, day)
        {days + epoch(), era}
      end

      @doc """
      Calculates the day of the year from the given
      `year`, `month`, and `day`.

      """
      @spec day_of_year(year, month, day) :: 1..366
      @impl true

      def day_of_year(year, month, day) do
        first_day = date_to_iso_days(year, 1, 1)
        this_day = date_to_iso_days(year, month, day)
        this_day - first_day + 1
      end

      if Code.ensure_loaded?(Date) && function_exported?(Date, :day_of_week, 2) do
        @last_day_of_week 5

        @spec day_of_week(year, month, day, :default | atom()) ::
                {Calendar.day_of_week(), first_day_of_week :: non_neg_integer(),
                 last_day_of_week :: non_neg_integer()}

        @impl true
        def day_of_week(year, month, day, :default) do
          days = date_to_iso_days(year, month, day)
          days_after_saturday = rem(days, @days_in_week)
          day = Cldr.Math.amod(days_after_saturday + @epoch_day_of_week, @days_in_week)

          {day, @epoch_day_of_week, @last_day_of_week}
        end

        defoverridable day_of_week: 4
      else
        @spec day_of_week(year, month, day) :: 1..7

        @impl true
        def day_of_week(year, month, day) do
          days = date_to_iso_days(year, month, day)
          days_after_saturday = rem(days, @days_in_week)
          Cldr.Math.amod(days_after_saturday + @epoch_day_of_week, @days_in_week)
        end

        defoverridable day_of_week: 3
      end

      @doc """
      Returns the number of periods in a given
      `year`. A period corresponds to a month
      in month-based calendars and a week in
      week-based calendars.

      """
      @impl true

      def periods_in_year(year) do
        months_in_year(year)
      end

      @doc """
      Returns the number of months in a
      given Chinese `year`.

      """
      @impl true

      def months_in_year(year) do
        if leap_year?(year), do: 13, else: 12
      end

      @doc """
      Returns the number of weeks in a
      given Chinese `year`.

      """
      @impl true

      def weeks_in_year(_year) do
        {:error, :not_defined}
      end

      @doc """
      Returns the number days in a given year.

      The year is the number of years since the
      Chinese epoch.

      """
      @impl true

      def days_in_year(year) do
        this_year = date_to_iso_days(year, 1, 1)
        next_year = date_to_iso_days(year + 1, 1, 1)
        next_year - this_year + 1
      end

      @doc """
      Returns how many days there are in the given year
      and month.

      Since months are determined by the number of
      days from one new moon to the next, there is
      no fixed number of days for a given month
      number.

      The month number is the ordinal month number
      which means that the numbers do not always
      increase monotoncally.

      """
      @spec days_in_month(year, month) :: 29..30
      @impl true

      def days_in_month(year, month) do
        start_of_this_month = date_to_iso_days(year, month, 1)
        start_of_next_month = new_moon_on_or_after(start_of_this_month + 1)
        start_of_next_month - start_of_this_month
      end

      @doc """
      Returns the number days in a a week.

      """
      def days_in_week do
        @days_in_week
      end

      @doc """
      Returns a `Date.Range.t` representing
      a given year.

      """
      @impl true

      def year(year) do
        last_month = months_in_year(year)
        days_in_last_month = days_in_month(year, last_month)

        with {:ok, start_date} <- Date.new(year, 1, 1, __MODULE__),
             {:ok, end_date} <- Date.new(year, last_month, days_in_last_month, __MODULE__) do
          Date.range(start_date, end_date)
        end
      end

      @doc """
      Returns a `Date.Range.t` representing
      a given quarter of a year.

      """
      @impl true

      def quarter(_year, _quarter) do
        {:error, :not_defined}
      end

      @doc """
      Returns a `Date.Range.t` representing
      a given month of a year.

      """
      @impl true

      def month(year, month) do
        starting_day = 1
        ending_day = days_in_month(year, month)

        with {:ok, start_date} <- Date.new(year, month, starting_day, __MODULE__),
             {:ok, end_date} <- Date.new(year, month, ending_day, __MODULE__) do
          Date.range(start_date, end_date)
        end
      end

      @doc """
      Returns a `Date.Range.t` representing
      a given week of a year.

      """
      @impl true

      def week(_year, _week) do
        {:error, :not_defined}
      end

      @doc """
      Adds an `increment` number of `date_part`s
      to a `year-month-day`.

      `date_part` can be `:months` only.

      """
      @impl true

      def plus(year, month, day, date_part, increment, options \\ [])

      def plus(year, month, day, :months, months, options) do
        months_in_year = months_in_year(year)
        {year_increment, new_month} = Cldr.Math.div_amod(month + months, months_in_year)
        new_year = year + year_increment

        new_day =
          if Keyword.get(options, :coerce, false) do
            max_new_day = days_in_month(new_year, new_month)
            min(day, max_new_day)
          else
            day
          end

        {new_year, new_month, new_day}
      end

      @doc """
      Returns the `t:Calendar.iso_days` format of
      the specified date.

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

      def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond) do
        {date_to_iso_days(year, month, day), time_to_day_fraction(hour, minute, second, microsecond)}
      end

      @doc """
      Converts the `t:Calendar.iso_days` format to the
      datetime format specified by this calendar.

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
        {year, month, day} = date_from_iso_days(days)
        {hour, minute, second, microsecond} = time_from_day_fraction(day_fraction)
        {year, month, day, hour, minute, second, microsecond}
      end

      @doc false
      calendar_impl()

      def parse_date(string) do
        Cldr.Calendar.Parse.parse_date(string, __MODULE__)
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

      @doc false
      @impl Calendar
      defdelegate parse_time(string), to: Calendar.ISO

      @doc false
      @impl Calendar
      defdelegate day_rollover_relative_to_midnight_utc, to: Calendar.ISO

      @doc false
      @impl Calendar
      defdelegate time_from_day_fraction(day_fraction), to: Calendar.ISO

      @doc false
      @impl Calendar
      defdelegate time_to_day_fraction(hour, minute, second, microsecond), to: Calendar.ISO

      @doc false
      @impl Calendar
      defdelegate date_to_string(year, month, day), to: Calendar.ISO

      @doc false
      @impl Calendar
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

      @doc false
      @impl Calendar
      defdelegate naive_datetime_to_string(
                    year,
                    month,
                    day,
                    hour,
                    minute,
                    second,
                    microsecond
                  ),
                  to: Calendar.ISO

      @doc false
      @impl Calendar
      defdelegate time_to_string(hour, minute, second, microsecond), to: Calendar.ISO

      @doc false
      @impl Calendar
      defdelegate valid_time?(hour, minute, second, microsecond), to: Calendar.ISO

      defoverridable valid_time?: 4
      defoverridable naive_datetime_to_string: 7
      defoverridable date_to_string: 3
      defoverridable time_to_day_fraction: 4
      defoverridable time_from_day_fraction: 1
      defoverridable day_rollover_relative_to_midnight_utc: 0
      defoverridable parse_time: 1
      defoverridable parse_naive_datetime: 1
      defoverridable parse_utc_datetime: 1
      defoverridable parse_date: 1
      defoverridable naive_datetime_from_iso_days: 1
      defoverridable naive_datetime_to_iso_days: 7

      defoverridable valid_date?: 3
      defoverridable year_of_era: 1
      defoverridable quarter_of_year: 3
      defoverridable month_of_year: 3
      defoverridable week_of_year: 3
      defoverridable iso_week_of_year: 3
      defoverridable week_of_month: 3
      defoverridable day_of_era: 3
      defoverridable day_of_year: 3

      defoverridable periods_in_year: 1
      defoverridable months_in_year: 1
      defoverridable weeks_in_year: 1
      defoverridable days_in_year: 1
      defoverridable days_in_month: 2
      defoverridable days_in_week: 0
      defoverridable year: 1
      defoverridable quarter: 2
      defoverridable month: 2
      defoverridable week: 2
      defoverridable plus: 5
      defoverridable plus: 6

      defoverridable epoch: 0
      defoverridable cldr_calendar_type: 0
      defoverridable calendar_base: 0

      defoverridable calendar_year: 3
      defoverridable extended_year: 3
      defoverridable related_gregorian_year: 3
      defoverridable cyclic_year: 3

    end
  end
end