defmodule Cldr.Calendar.Base.Week do
  alias Cldr.Calendar.Base
  alias Cldr.Calendar.Config
  alias Calendar.ISO
  alias Cldr.Math

  @days_in_week 7
  @weeks_in_quarter 13
  @months_in_quarter 3
  @weeks_in_long_year 53
  @weeks_in_normal_year 52
  @months_in_year 12

  defmacro __using__(options \\ []) do
    quote bind_quoted: [options: options] do
      @options options
      @before_compile Cldr.Calendar.Compiler.Week
    end
  end

  def valid_date?(year, week, day, config) do
    max_weeks = if long_year?(year, config), do: @weeks_in_long_year, else: @weeks_in_normal_year
    week <= max_weeks and day in 1..@days_in_week
  end

  # Quarters are 13 weeks but if there
  # are 53 weeks in a year then 4th
  # quarter is longer
  def quarter_of_year(_year, @weeks_in_long_year, _day, _config) do
    4
  end

  def quarter_of_year(_year, week, _day, _config) do
    div(week - 1, @weeks_in_quarter) + 1
  end

  def month_of_year(_year, @weeks_in_long_year, _day, _config) do+
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

  def days_in_month(year, @months_in_year, config) do
    %Config{weeks_in_month: {_, _, weeks_in_month}} = config
    if long_year?(year, config) do
      (weeks_in_month + 1) * @days_in_week
    else
      weeks_in_month * @days_in_week
    end
  end

  @doc """
  Returns the `iso_days` that is the first
  day of the `year`.

  Note that by convention, the `year` is the
  gregorian year in which the year ends.

  """
  def first_day_of_year(year, %Config{anchor: :first} = config) do
    %{month: first_month, day: first_day, min_days: min_days} = config
    iso_days = ISO.date_to_iso_days(year, first_month, min_days)
    day_of_week = Cldr.Calendar.iso_days_to_day_of_week(iso_days)

    if first_day < day_of_week do
      iso_days - (day_of_week - first_day)
    else
      iso_days + (day_of_week - first_day)
    end
  end

  def last_week_starts(year, %Config{anchor: :first} = config) do
    %{month: first_month, day: first_day, min_days: min_days} = config
    months_in_year = ISO.months_in_year(year)
    last_month_of_year = Cldr.Math.amod(first_month - 1, months_in_year)
    days_in_month = ISO.days_in_month(year, last_month_of_year)
    iso_days = ISO.date_to_iso_days(year, last_month_of_year, days_in_month - min_days + 1)
    day_of_week = Cldr.Calendar.iso_days_to_day_of_week(iso_days)

    if first_day < day_of_week do
      iso_days - (day_of_week - first_day + 1)
    else
      iso_days + (day_of_week - first_day + 1)
    end
  end

  def last_day_of_year(year, config) do
    last_week_starts(year, config) + @days_in_week
  end

  def long_year?(year, %Config{} = config) do
    first_day = first_day_of_year(year, config)
    last_day = last_day_of_year(year, config)
    days_in_year = last_day - first_day + 1
    div(days_in_year, @days_in_week) == @weeks_in_long_year
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
