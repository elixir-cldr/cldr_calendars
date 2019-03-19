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

  def quarter_of_year(_year, month, _day, _config) do
    div(month - 1, @quarters_in_year) + 1
  end

  def month_of_year(_year, month, _day, _config) do
    month
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
    week_of_year(year, month, day, %Config{
      day: @iso_week_first_day,
      min_days: @iso_week_min_days,
      month: @january
    })
  end

  def day_of_era(_year, _week, _day, _config) do
  end

  def day_of_week(year, month, day, config) do
    {year, month, day} = date_to_iso_date(year, month, day, config)
    ISO.day_of_week(year, month, day)
  end

  def day_of_year(_year, _month, _day, _config) do
  end

  def days_in_year(year, config) do
    if leap_year?(year, config), do: 366, else: 365
  end

  def days_in_month(year, month, config) do
    {iso_year, iso_month, _day} = date_to_iso_date(year, month, 1, config)
    ISO.days_in_month(iso_year, iso_month)
  end

  @doc """
  Returns the `iso_days` that is the first
  day of the `year`.

  Note that by convention, the `year` is the
  gregorian year in which the year ends.

  """
  def first_day_of_year(year, %Config{month: 1}) do
    ISO.date_to_iso_days(year, 1, 1)
  end

  def first_day_of_year(year, %Config{month: first_month} = config) do
    beginning_year = Cldr.Calendar.beginning_gregorian_year(year, config)
    ISO.date_to_iso_days(beginning_year, first_month, 1)
  end

  def last_day_of_year(year, %Config{month: first_month} = config) do
    ending_year = Cldr.Calendar.ending_gregorian_year(year, config)
    last_month = Math.amod(first_month - 1, ISO.months_in_year(ending_year))
    last_day = ISO.days_in_month(ending_year, last_month)
    ISO.date_to_iso_days(ending_year, last_month, last_day)
  end

  def leap_year?(year, %Config{month: 1}) do
    ISO.leap_year?(year)
  end

  def leap_year?(year, config) do
    days_in_year = last_day_of_year(year, config) - first_day_of_year(year, config) + 1
    days_in_year == 366
  end

  def naive_datetime_from_iso_days(iso_days, %Config{month: 1}) do
    ISO.naive_datetime_from_iso_days(iso_days)
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
