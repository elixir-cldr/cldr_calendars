defmodule Cldr.Calendar.Base.Month do
  @moduledoc """
  Implements the `Calendar` behaviour for the
  Gregorian proleptic calendar.

  In this regard it implements the same
  calendar as the Elixir `Calendar.ISO`
  calendar but adds the `Cldr.Calendar`
  behaviour.

  This behaviour adds the following
  functions:

  * `week_of_year/4` and `iso_week_of_year/3`
    functions.

  """

  alias Cldr.Calendar.Config
  alias Cldr.Calendar.Base
  alias Calendar.ISO
  alias Cldr.Math

  @days_in_week 7
  @quarters_in_year 4
  @months_in_quarter 3
  @iso_week_first_day 1
  @iso_week_min_days 4
  @january 1

  defmacro __using__(options \\ []) do
    quote bind_quoted: [options: options] do
      @options options
      @before_compile Cldr.Calendar.Compiler.Month
    end
  end

  def valid_date?(year, month, day, %Config{month: 1}) do
    Calendar.ISO.valid_date?(year, month, day)
  end

  def valid_date?(year, month, day, config) do
    {year, month, day} = date_to_iso_date(year, month, day, config)
    Calendar.ISO.valid_date?(year, month, day)
  end

  def year_of_era(year, config) do
    year
    |> Cldr.Calendar.ending_gregorian_year(config)
    |> Calendar.ISO.year_of_era
  end

  def quarter_of_year(_year, month, _day, _config) do
    Float.ceil(month / @months_in_quarter)
    |> trunc
  end

  def month_of_year(_year, month, _day, _config) do
    month
  end

  def week_of_year(year, month, day, config) do
    iso_days = date_to_iso_days(year, month, day, config)
    first_gregorian_day_of_year = Base.Week.first_gregorian_day_of_year(year, config)
    last_gregorian_day_of_year = Base.Week.last_gregorian_day_of_year(year, config)

    cond do
      iso_days < first_gregorian_day_of_year ->
        if Base.Week.long_year?(year - 1, config), do: {year - 1, 53}, else: {year - 1, 52}

      iso_days > last_gregorian_day_of_year ->
        {year + 1, 1}

      true ->
        week = div(iso_days - first_gregorian_day_of_year, @days_in_week) + 1
        {year, week}
    end
  end

  def iso_week_of_year(year, month, day) do
    week_of_year(year, month, day, %Config{
      day: @iso_week_first_day,
      min_days: @iso_week_min_days,
      month: @january
    })
  end

  def day_of_era(year, month, day, config) do
    {year, month, day} = date_to_iso_date(year, month, day, config)
    Calendar.ISO.day_of_era(year, month, day)
  end

  def day_of_year(year, month, day, config) do
    {iso_year, iso_month, iso_day} = date_to_iso_date(year, month, day, config)
    iso_days = Calendar.ISO.date_to_iso_days(iso_year, iso_month, iso_day)
    iso_days - first_gregorian_day_of_year(year, config) + 1
  end

  def day_of_week(year, month, day, config) do
    {year, month, day} = date_to_iso_date(year, month, day, config)
    ISO.day_of_week(year, month, day)
  end

  def months_in_year(year, _config) do
    Calendar.ISO.months_in_year(year)
  end

  def days_in_year(year, config) do
    if leap_year?(year, config), do: 366, else: 365
  end

  def days_in_month(year, month, config) do
    {iso_year, iso_month, _day} = date_to_iso_date(year, month, 1, config)
    ISO.days_in_month(iso_year, iso_month)
  end

  def days_in_week do
    @days_in_week
  end

  def days_in_week(_year, _week) do
    @days_in_week
  end

  def year(year, config) do
    calendar = config.calendar
    last_month = calendar.months_in_year(year)
    days_in_last_month  = calendar.days_in_month(year, last_month)

    {:ok, start_date} = Date.new(year, 1, 1, config.calendar)
    {:ok, end_date} = Date.new(year, last_month, days_in_last_month, config.calendar)

    Date.range(start_date, end_date)
  end

  def quarter(year, quarter, config) do
    months_in_quarter = div(months_in_year(year, config), @quarters_in_year)
    starting_month = (months_in_quarter * (quarter - 1)) + 1
    starting_day = 1

    ending_month = starting_month + months_in_quarter - 1
    ending_day = days_in_month(year, ending_month, config)

    with {:ok, start_date} <- Date.new(year, starting_month, starting_day, config.calendar),
         {:ok, end_date} <- Date.new(year, ending_month, ending_day, config.calendar) do
      Date.range(start_date, end_date)
    end
  end

  def month(year, month, config) do
    starting_day = 1
    ending_day = days_in_month(year, month, config)

    with {:ok, start_date} <- Date.new(year, month, starting_day, config.calendar),
         {:ok, end_date} <- Date.new(year, month, ending_day, config.calendar) do
      Date.range(start_date, end_date)
    end
  end

  def week(year, week, config) do
    starting_day = Cldr.Calendar.Base.Week.first_gregorian_day_of_year(year, config) +
      Cldr.Calendar.weeks_to_days(week - 1)

    ending_day = (starting_day + days_in_week() - 1)

    with {:ok, start_date} <- date_from_iso_days(starting_day, config),
         {:ok, end_date} <- date_from_iso_days(ending_day, config) do
      Date.range(start_date, end_date)
    end
  end

  def plus(year, month, day, config, :quarters, quarters) do
    months = (quarters * @months_in_quarter)
    plus(year, month, day, config, :months, months)
  end

  def plus(year, month, day, config, :months, months) do
    months_in_year = months_in_year(year, config)
    {year_increment, new_month} = Cldr.Math.div_amod(month + months, months_in_year)
    # This is the original code for the line above - just in case!
    # {year_increment, new_month} = Cldr.Math.div_mod(month + months, months_in_year)
    # {year_increment, new_month} =
    #   if new_month == 0 do
    #     {year_increment - 1, months_in_year}
    #   else
    #     {year_increment, new_month}
    #   end
    new_year = year + year_increment
    max_new_day = days_in_month(new_year, new_month, config)
    new_day = min(day, max_new_day)
    {new_year, new_month, new_day}
  end

  @doc """
  Returns the `iso_days` that is the first
  day of the `year`.

  Note that by convention, the `year` is the
  gregorian year in which the year ends.

  """
  def first_gregorian_day_of_year(year, %Config{month: 1}) do
    ISO.date_to_iso_days(year, 1, 1)
  end

  def first_gregorian_day_of_year(year, %Config{month: first_month} = config) do
    beginning_year = Cldr.Calendar.beginning_gregorian_year(year, config)
    ISO.date_to_iso_days(beginning_year, first_month, 1)
  end

  def last_gregorian_day_of_year(year, %Config{month: first_month} = config) do
    ending_year = Cldr.Calendar.ending_gregorian_year(year, config)
    last_month = Math.amod(first_month - 1, ISO.months_in_year(ending_year))
    last_day = ISO.days_in_month(ending_year, last_month)
    ISO.date_to_iso_days(ending_year, last_month, last_day)
  end

  def leap_year?(year, %Config{month: 1}) do
    ISO.leap_year?(year)
  end

  def leap_year?(year, config) do
    days_in_year = last_gregorian_day_of_year(year, config) - first_gregorian_day_of_year(year, config) + 1
    days_in_year == 366
  end

  def date_to_iso_days(year, month, day, config) do
    {days, _day_fraction} = naive_datetime_to_iso_days(year, month, day, 0, 0, 0, {0, 6}, config)
    days
  end

  def date_from_iso_days(iso_day_number, config) do
   {year, month, day, _, _, _, _} = naive_datetime_from_iso_days(iso_day_number, config)
   Date.new(year, month, day, config.calendar)
  end

  def naive_datetime_from_iso_days(iso_day_number, config) when is_integer(iso_day_number) do
    naive_datetime_from_iso_days({iso_day_number, {0, 6}}, config)
  end

  def naive_datetime_from_iso_days({days, day_fraction}, config) do
    {year, month, day} = Calendar.ISO.date_from_iso_days(days)
    {year, month, day} = date_from_iso_date(year, month, day, config)
    {hour, minute, second, microsecond} = Calendar.ISO.time_from_day_fraction(day_fraction)
    {year, month, day, hour, minute, second, microsecond}
  end

  def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond, config) do
    {year, month, day} = date_to_iso_date(year, month, day, config)
    ISO.naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond)
  end

  def date_to_iso_date(year, month, day, %Config{month: first_month}) do
    iso_month = Math.amod(month + first_month - 1, ISO.months_in_year(year))

    iso_year =
      if month - first_month < 0 do
        year - 1
      else
        year
      end

    {iso_year, iso_month, day}
  end

  def date_from_iso_date(iso_year, iso_month, day, %Config{month: first_month}) do
    month = Math.amod(iso_month - first_month + 1, ISO.months_in_year(iso_year))

    year =
      if month - iso_month < 0 do
        iso_year + 1
      else
        iso_year
      end

    {year, month, day}
  end

end
