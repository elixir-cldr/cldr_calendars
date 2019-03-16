defmodule Cldr.Calendar.Base.Week do
  alias Cldr.Calendar.Base
  alias Cldr.Calendar.Config
  alias Cldr.Math

  @days_in_week 7
  @weeks_in_quarter 13
  @months_in_quarter 3

  defmacro __using__(options \\ []) do
    quote bind_quoted: [options: options] do
      @options options
      @before_compile Cldr.Calendar.Compiler.Week
    end
  end

  def valid_date?(year, week, day, config) do
    max_weeks = if leap_year?(year, config), do: 53, else: 52
    week <= max_weeks and day in 1..7
  end

  # Quarters are 13 weeks but if there
  # are 53 weeks in a year then 4th
  # quarter is longer
  def quarter_of_year(_year, 53, _day, _config) do
    4
  end

  def quarter_of_year(_year, week, _day, _config) do
    div(week - 1, @weeks_in_quarter) + 1
  end

  def month_of_year(_year, 53, _day, _config) do+
    12
  end

  def month_of_year(year, week, day, config) do
    %Config{weeks_in_month: {m1, m2, m3}} = config
    {m1, m2, m3} = {m1, m1 + m2, m1 + m2 + m3}
    quarter = quarter_of_year(year, week, day, config)
    offset_month = (quarter - 1) * @months_in_quarter
    week_in_quarter = Math.amod(week, @weeks_in_quarter)

    cond do
      week_in_quarter <= m1 ->
        offset_month + 1
      week_in_quarter <= m2 ->
        offset_month + 2
      week_in_quarter <= m3 ->
        offset_month + 3
    end
  end

  def week_of_year(_year, week, _day, _config) do
    week
  end

  def iso_week_of_year(year, week, day, config) do
    {:ok, date} = Date.new(year, week, day, config.calendar)
    {:ok, %{year: year, month: month, day: day}} = Date.convert(date, Base.Month)
    Base.Month.iso_week_of_year(year, month, day)
  end

  def day_of_era(_year, _week, _day, _config) do

  end

  def day_of_year(year, week, day, config) do
    first_day_of_year(year, config) + week_to_days(week) + day
  end

  def day_of_week(_year, _week, day, config) do
    first_day = config.first_day
    Math.amod(first_day + day, @days_in_week)
  end

  def days_in_month(_year, month, config) when month in 1..11 do
    %Config{weeks_in_month: weeks_in_month} = config
    month_in_quarter = Math.amod(rem(month, @months_in_quarter), @months_in_quarter)
    elem(weeks_in_month, month_in_quarter - 1) * @days_in_week
  end

  def days_in_month(year, 12, config) do
    %Config{weeks_in_month: {_, _, weeks_in_month}} = config
    if leap_year?(year, config) do
      (weeks_in_month + 1) * @days_in_week
    else
      weeks_in_month * @days_in_week
    end
  end

  def leap_year?(year, config) do
    Cldr.Calendar.Week.long_year?(year, config)
  end

  def first_day_of_year(year, config) do
    Cldr.Calendar.Week.first_week_starts(year, config)
  end

  def last_day_of_year(year, config) do
    Cldr.Calendar.Week.last_week_ends(year, config)
  end

  def date_to_string(year, week, day) do
    "#{year}-W#{lpad(week)}-#{day}"
  end

  def naive_datetime_from_iso_days({days, day_fraction}, config) do
    {year, month, day} = Calendar.ISO.date_from_iso_days(days)
    {year, week} = Base.Month.iso_week_of_year(year, month, day)
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
      Cldr.Calendar.offset_to_string(utc_offset, std_offset, time_zone) <>
      Cldr.Calendar.zone_to_string(utc_offset, std_offset, zone_abbr, time_zone)
  end

  defp lpad(week) when week < 10 do
    "0#{week}"
  end

  defp lpad(week) do
    week
  end

  defp week_to_days(week) do
    (week - 1) * @days_in_week
  end

end
