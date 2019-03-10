defmodule Cldr.Calendar.Week do
  @behaviour Calendar
  # @behaviour Cldr.Calendar

  alias Cldr.Calendar.Options
  alias Cldr.Calendar.Gregorian

  @days_in_week 7
  @weeks_per_quarter 13

  @iso_week_first_day 1
  @iso_week_min_days 4

  @calendar_options %Options{min_days: @iso_week_min_days, first_day: @iso_week_first_day}

  defmacro __using__(options \\ []) do
    quote bind_quoted: [options: options] do
      @options options
      @before_compile Cldr.Calendar.Backend.Compiler
    end
  end

  def quarter_name(year, week, day, options \\ []) do
    with options <- Gregorian.extract_options(options) do
      quarter =  quarter_of_year(year, week, day)
      get_in(options.module.quarter(options.locale), [:format, options.format, quarter])
    end
  end

  def valid_date?(year, week, day) do
    max_weeks = if leap_year?(year), do: 53, else: 52
    week <= max_weeks and day in 1..7
  end

  def date_to_string(year, week, day) do
    "#{year}-W#{lpad(week)}-#{day}"
  end

  def days_in_month(_year, _month) do

  end

  def leap_year?(year) do
    Cldr.Calendar.Gregorian.long_year?(year, @calendar_options)
  end

  # Quarters are 13 weeks but if there
  # are 53 weeks in a year then 4th
  # quarter is longer
  def quarter_of_year(_year, 53, _day) do
    4
  end

  def quarter_of_year(_year, week, _day) do
    div(week - 1, @weeks_per_quarter) + 1
  end

  def month_of_year(_year, _week, _day) do

  end

  def week_of_year(_year, week, _day) do
    week
  end

  def day_of_year(year, week, day) do
    first_day = first_day_of_year(year)
    first_day + ((week - 1) * @days_in_week) + day
  end

  def day_of_era(_year, _week, _day) do

  end

  def first_day_of_year(year) do
    Cldr.Calendar.Gregorian.first_week_starts(year, @calendar_options)
  end

  def last_day_of_year(year) do
    Cldr.Calendar.Gregorian.last_week_ends(year, @calendar_options)
  end

  def naive_datetime_from_iso_days({days, day_fraction}) do
    {year, month, day} = Calendar.ISO.date_from_iso_days(days)
    {year, week} = Gregorian.iso_week_of_year(year, month, day, @calendar_options)
    day = days - first_day_of_year(year) - week_to_days(week)
    {hour, minute, second, microsecond} = Calendar.ISO.time_from_day_fraction(day_fraction)
    {year, week, day, hour, minute, second, microsecond}
  end

  defp week_to_days(week) do
    (week - 1) * @days_in_week
  end

  def naive_datetime_to_iso_days(year, week, day, hour, minute, second, microsecond) do
    days = first_day_of_year(year) + week_to_days(week) + day
    moment = Calendar.ISO.time_to_day_fraction(hour, minute, second, microsecond)
    {days, moment}
  end

  def datetime_to_string(year, month, day, hour, minute, second, microsecond, time_zone, zone_abbr, utc_offset, std_offset) do
    date_to_string(year, month, day) <>
      " " <>
      Calendar.ISO.time_to_string(hour, minute, second, microsecond) <>
      Gregorian.offset_to_string(utc_offset, std_offset, time_zone) <>
      Gregorian.zone_to_string(utc_offset, std_offset, zone_abbr, time_zone)
  end

  def day_of_week(_year, _week, day) do
    first_day = @calendar_options.first_day
    Cldr.Math.amod(first_day + day, 7)
  end

  defdelegate day_rollover_relative_to_midnight_utc, to: Calendar.ISO
  defdelegate months_in_year(year), to: Calendar.ISO
  defdelegate naive_datetime_to_string(year, month, day, hour, minute, second, microsecond), to: Calendar. ISO
  defdelegate time_from_day_fraction(day_fraction), to: Calendar.ISO
  defdelegate time_to_day_fraction(hour, minute, second, microsecond), to: Calendar.ISO
  defdelegate time_to_string(hour, minute, second, microsecond), to: Calendar.ISO
  defdelegate valid_time?(hour, minute, second, microsecond), to: Calendar.ISO
  defdelegate year_of_era(year), to: Calendar.ISO

  defp lpad(week) when week < 10 do
    "0#{week}"
  end

  defp lpad(week) do
    week
  end
end

