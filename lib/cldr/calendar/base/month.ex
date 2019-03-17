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
  @iso_week_first_day 1
  @iso_week_min_days 4
  @january 1

  defmacro __using__(options \\ []) do
    quote bind_quoted: [options: options] do
      @options options
      @before_compile Cldr.Calendar.Compiler.Month
    end
  end

  def valid_date?(year, month, day, config) do

  end

  def quarter_of_year(year, month, day, config) do

  end

  def month_of_year(year, month, day, config) do

  end

  def day_of_era(_year, _week, _day, _config) do

  end

  def day_of_week(year, month, day, config) do

  end

  def day_of_year(year, month, day, config) do

  end

  def days_in_year(year, config) do
    if leap_year?(year, config), do: 366, else: 365
  end

  # Incorrect - month is an offset from the
  # first month of year
  def days_in_month(year, month, config) do
    ISO.days_in_month(year, month)
  end

  def week_of_year(year, month, day, %Config{} = config) do
    iso_days = ISO.date_to_iso_days(year, month, day)
    first_day_of_year = Base.Week.first_day_of_year(year, config)
    last_day_of_year = Base.Week.last_day_of_year(year, config)

    cond do
      iso_days < first_day_of_year ->
        if Base.Week.long_year?(year - 1, config), do: {year - 1, 53}, else: {year - 1, 52}

      iso_days > last_day_of_year ->
        {year + 1, 1}

      true ->
        week = div(iso_days - first_day_of_year, @days_in_week) + 1
        {year, week}
    end
  end

  def iso_week_of_year(year, month, day) do
    week_of_year(year, month, day,
      %Config{first_day: @iso_week_first_day, min_days: @iso_week_min_days, first_month: @january})
  end

  @doc """
  Returns the `iso_days` that is the first
  day of the `year`.

  Note that by convention, the `year` is the
  gregorian year in which the year ends.

  """
  def first_day_of_year(year, %Config{first_month: 1}) do
    ISO.date_to_iso_days(year, 1, 1)
  end

  def first_day_of_year(year, %Config{first_month: first_month, calendar: calendar}) do
    ISO.date_to_iso_days(year - 1, first_month, 1)
  end

  def last_day_of_year(year, %Config{first_month: first_month, calendar: calendar}) do
    last_month = Math.amod(first_month - 1, ISO.months_in_year(year))
    last_day = ISO.days_in_month(year, last_month)
    ISO.date_to_iso_days(year, last_month, last_day)
  end

  def leap_year?(year, %Config{first_month: 1}) do
    ISO.leap_year?(year)
  end

  def leap_year?(year, config) do
    days_in_year = last_day_of_year(year, config) - first_day_of_year(year, config) + 1
    days_in_year == 366
  end

  def naive_datetime_from_iso_days(iso_days, config) do

  end

  def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond, config) do

  end

end
