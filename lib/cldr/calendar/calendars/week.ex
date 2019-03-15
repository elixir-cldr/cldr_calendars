defmodule Cldr.Calendar.Week do
  alias Cldr.Calendar.Gregorian

  @days_in_week 7
  @weeks_per_quarter 13

  defmacro __using__(options \\ []) do
    quote bind_quoted: [options: options] do
      @options options
      @before_compile Cldr.Calendar.Backend.Compiler
    end
  end

  def valid_date?(year, week, day, config) do
    max_weeks = if leap_year?(year, config), do: 53, else: 52
    week <= max_weeks and day in 1..7
  end

  def date_to_string(year, week, day) do
    "#{year}-W#{lpad(week)}-#{day}"
  end

  def days_in_month(_year, _week, _config) do

  end

  def leap_year?(year, config) do
    Cldr.Calendar.Gregorian.long_year?(year, config)
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

  def month_of_year(_year, _week, _day, _config) do

  end

  def week_of_year(_year, week, _day) do
    week
  end

  def day_of_year(year, week, day, config) do
    first_day = first_day_of_year(year, config)
    first_day + (week - 1) * @days_in_week + day
  end

  defp week_to_days(week) do
    (week - 1) * @days_in_week
  end

  def day_of_era(_year, _week, _day, _config) do

  end

  def first_day_of_year(year, config) do
    Cldr.Calendar.Gregorian.first_week_starts(year, config)
  end

  def last_day_of_year(year, config) do
    Cldr.Calendar.Gregorian.last_week_ends(year, config)
  end

  def naive_datetime_from_iso_days({days, day_fraction}, config) do
    {year, month, day} = Calendar.ISO.date_from_iso_days(days)
    {year, week} = Gregorian.iso_week_of_year(year, month, day)
    day = days - first_day_of_year(year, config) - week_to_days(week)
    {hour, minute, second, microsecond} = Calendar.ISO.time_from_day_fraction(day_fraction)
    {year, week, day, hour, minute, second, microsecond}
  end

  def naive_datetime_to_iso_days(year, week, day, hour, minute, second, microsecond, config) do
    days = first_day_of_year(year, config) + week_to_days(week) + day
    moment = Calendar.ISO.time_to_day_fraction(hour, minute, second, microsecond)
    {days, moment}
  end

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
    date_to_string(year, month, day) <>
      " " <>
      Calendar.ISO.time_to_string(hour, minute, second, microsecond) <>
      Gregorian.offset_to_string(utc_offset, std_offset, time_zone) <>
      Gregorian.zone_to_string(utc_offset, std_offset, zone_abbr, time_zone)
  end

  def day_of_week(_year, _week, day, config) do
    first_day = config.first_day
    Cldr.Math.amod(first_day + day, 7)
  end

  defp lpad(week) when week < 10 do
    "0#{week}"
  end

  defp lpad(week) do
    week
  end
end
