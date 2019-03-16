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
  alias Cldr.Calendar.Week

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

  def days_in_year(year) do
    if Calendar.ISO.leap_year?(year), do: 365, else: 366
  end

  def days_in_month(year, month, config) do
    Calendar.ISO.days_in_month(year, month)
  end

  def leap_year?(year, config) do

  end

  def week_of_year(year, month, day, config) do

  end

  def iso_week_of_year(year, month, day) do
    Week.week_of_year(year, month, day,
      %Config{first_day: @iso_week_first_day, min_days: @iso_week_min_days, first_month: @january})
  end

  def first_week_starts(year, config) do

  end

  def last_week_ends(year, config) do

  end

  def first_day_of_year(year, config \\ %Config{}) do
    Week.first_week_starts(year, config)
  end

  def last_day_of_year(year, config \\ %Config{}) do
    Week.last_week_ends(year, config)
  end


  def naive_datetime_from_iso_days(iso_days, config) do

  end

  def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond, config) do

  end

end
