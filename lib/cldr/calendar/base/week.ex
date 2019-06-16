defmodule Cldr.Calendar.Base.Week do
  @moduledoc false

  alias Cldr.Calendar.Config
  alias Cldr.Calendar.Base.Month
  alias Calendar.ISO
  alias Cldr.Math

  @days_in_week 7
  @weeks_in_quarter 13
  @months_in_quarter 3
  @months_in_year 12
  @weeks_in_long_year 53
  @weeks_in_normal_year 52

  defmacro __using__(options \\ []) do
    quote bind_quoted: [options: options] do
      @options options
      @before_compile Cldr.Calendar.Compiler.Week
    end
  end

  def valid_date?(year, week, day, config) do
    week <= weeks_in_year(year, config) and day in 1..days_in_week()
  end

  def year_of_era(year, config) do
    {_, year} = Cldr.Calendar.start_end_gregorian_years(year, config)
    Calendar.ISO.year_of_era(year)
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

  def month_of_year(_year, @weeks_in_long_year, _day, _config) do
    +12
  end

  def month_of_year(year, week, day, %Config{weeks_in_month: weeks_in_month} = config) do
    quarter = quarter_of_year(year, week, day, config)
    months_in_prior_quarters = (quarter - 1) * @months_in_quarter

    week_in_quarter = Math.amod(week, @weeks_in_quarter)
    [m1, m2, _m3] = weeks_in_month

    month_in_quarter =
      cond do
        week_in_quarter <= m1 -> 1
        week_in_quarter <= m1 + m2 -> 2
        true -> 3
      end

    months_in_prior_quarters + month_in_quarter
  end

  def week_of_year(year, week, _day, _config) do
    {year, week}
  end

  def iso_week_of_year(year, week, day, config) do
    with {:ok, date} <- Date.new(year, week, day, config.calendar) do
      {:ok, %{year: year, month: month, day: day}} = Date.convert(date, Cldr.Calendar.Gregorian)
      Cldr.Calendar.Gregorian.iso_week_of_year(year, month, day)
    end
  end

  def week_of_month(year, week, day, config) do
    month = month_of_year(year, week, day, config)
    %Date.Range{first: first} = month(year, month, config)
    {month, week - first.month + 1}
  end

  def day_of_era(year, week, day, config) do
    with {:ok, date} <- Date.new(year, week, day, config.calendar) do
      {:ok, %{year: year, month: month, day: day}} = Date.convert(date, Calendar.ISO)
      Calendar.ISO.day_of_era(year, month, day)
    end
  end

  def day_of_year(year, week, day, config) do
    start_of_year = first_gregorian_day_of_year(year, config)
    this_day = first_gregorian_day_of_year(year, config) + week_to_days(week) + day
    this_day - start_of_year + 1
  end

  def day_of_week(_year, _week, day, %{first_or_last: :first} = config) do
    first_day = config.first_day_of_year
    Math.amod(first_day + day - 1, days_in_week())
  end

  def day_of_week(_year, _week, day, %{first_or_last: :last} = config) do
    last_day = config.first_day_of_year
    Math.amod(last_day + day, days_in_week())
  end

  def months_in_year(year, _config) do
    Calendar.ISO.months_in_year(year)
  end

  def weeks_in_year(year, config) do
    if long_year?(year, config), do: weeks_in_long_year(), else: weeks_in_normal_year()
  end

  def weeks_in_long_year do
    @weeks_in_long_year
  end

  def weeks_in_normal_year do
    @weeks_in_normal_year
  end

  def days_in_year(year, config) do
    if long_year?(year, config) do
      @weeks_in_long_year * @days_in_week
    else
      @weeks_in_normal_year * @days_in_week
    end
  end

  def days_in_month(year, @months_in_year, config) do
    %Config{weeks_in_month: [_, _, weeks_in_last_month]} = config
    weeks = if long_year?(year, config), do: weeks_in_last_month + 1, else: weeks_in_last_month
    weeks * days_in_week()
  end

  def days_in_month(_year, month, config) do
    %Config{weeks_in_month: weeks_in_month} = config
    month_in_quarter = Math.amod(rem(month, @months_in_quarter), @months_in_quarter)
    Enum.at(weeks_in_month, month_in_quarter - 1) * days_in_week()
  end

  def days_in_week do
    @days_in_week
  end

  def days_in_week(_year, _week) do
    @days_in_week
  end

  def year(year, config) do
    with {:ok, first_day} <- Date.new(year, 1, 1, config.calendar),
         {:ok, last_day} <-
           Date.new(year, weeks_in_year(year, config), days_in_week(), config.calendar) do
      Date.range(first_day, last_day)
    end
  end

  def quarter(year, quarter, config) do
    starting_week = (quarter - 1) * @weeks_in_quarter + 1
    ending_week = starting_week + @weeks_in_quarter - 1

    with {:ok, first_day} <- Date.new(year, starting_week, 1, config.calendar),
         {:ok, last_day} <- Date.new(year, ending_week, days_in_week(), config.calendar) do
      Date.range(first_day, last_day)
    end
  end

  def month(year, month, %{weeks_in_month: weeks_in_month} = config) do
    months_prior_in_quarter = rem(month - 1, @months_in_quarter)
    prior_quarters = Month.quarter_of_year(year, month, 1, config) - 1
    quarter_weeks_prior = prior_quarters * @weeks_in_quarter

    weeks_prior_in_quarter =
      weeks_in_month
      |> Enum.take(months_prior_in_quarter)
      |> Enum.sum()

    weeks_in_month =
      Enum.at(weeks_in_month, months_prior_in_quarter) +
        long_year_inc(year, month, config)

    first_week = quarter_weeks_prior + weeks_prior_in_quarter + 1
    last_week = first_week + weeks_in_month - 1

    {:ok, start_of_month} = Date.new(year, first_week, 1, config.calendar)
    {:ok, end_of_month} = Date.new(year, last_week, days_in_week(), config.calendar)

    Date.range(start_of_month, end_of_month)
  end

  def week(year, week, config) do
    with {:ok, first_day} <- Date.new(year, week, 1, config.calendar),
         {:ok, last_day} <- Date.new(year, week, days_in_week(), config.calendar) do
      Date.range(first_day, last_day)
    end
  end

  def plus(year, week, day, config, :quarters, quarters, _options) do
    days = quarters * @weeks_in_quarter * days_in_week()
    iso_days = date_to_iso_days(year, week, day, config) + days
    date_from_iso_days(iso_days, config)
  end

  def plus(year, week, day, config, :months, months, _options) do
    {quarters, months_remaining} = Cldr.Math.div_mod(months, @months_in_quarter)
    weeks_from_months = weeks_from_months(months_remaining, config)
    days = (quarters * @weeks_in_quarter + weeks_from_months) * days_in_week() * sign(months)
    iso_days = date_to_iso_days(year, week, day, config) + days
    date_from_iso_days(iso_days, config)
  end

  def weeks_from_months(months, _config) when months == 0 do
    0
  end

  # When months is positive we just sum the first n members of the
  # weeks_in_month list.
  def weeks_from_months(months, %{weeks_in_month: weeks_in_month}) when months > 0 do
    weeks_in_month
    |> Enum.take(months)
    |> Enum.sum()
  end

  def weeks_from_months(months, %{weeks_in_month: weeks_in_month}) when months < 0 do
    {_, weeks_in_month} = List.pop_at(weeks_in_month, -1)
    Enum.take(weeks_in_month, months) |> Enum.sum()
  end

  # For weeks <= 13
  def month_from_weeks(weeks, %Config{weeks_in_month: [m1, m2, m3]}) do
    cond do
      weeks <= m1 -> 1
      weeks <= m1 + m2 -> 2
      weeks <= m1 + m2 + m3 -> 3
    end
  end

  defp sign(number) when number < 0, do: -1
  defp sign(_number), do: +1

  def first_gregorian_day_of_year(year, %Config{first_or_last: :first} = config) do
    {year, _} = Cldr.Calendar.start_end_gregorian_years(year, config)

    %{
      first_month_of_year: first_month,
      first_day_of_year: first_day,
      min_days_in_first_week: min_days
    } = config

    iso_days = ISO.date_to_iso_days(year, first_month, min_days)
    day_of_week = Cldr.Calendar.iso_days_to_day_of_week(iso_days)

    # The iso_days calulation is the last possible first day of the first week
    # All starting days are less than or equal to this day
    if first_day > day_of_week do
      iso_days + (first_day - days_in_week() - day_of_week)
    else
      iso_days - (day_of_week - first_day)
    end
  end

  def first_gregorian_day_of_year(year, %Config{first_or_last: :last} = config) do
    last_gregorian_day_of_year(year - 1, config) + 1
  end

  def last_gregorian_day_of_year(year, %Config{first_or_last: :first} = config) do
    first_gregorian_day_of_year(year + 1, config) - 1
  end

  def last_gregorian_day_of_year(year, %Config{first_or_last: :last} = config) do
    {_, year} = Cldr.Calendar.start_end_gregorian_years(year, config)

    %{
      first_month_of_year: last_month,
      first_day_of_year: last_day,
      min_days_in_first_week: min_days
    } = config

    days_in_last_month = ISO.days_in_month(year, last_month)
    iso_days = ISO.date_to_iso_days(year, last_month, days_in_last_month - min_days)
    day_of_week = Cldr.Calendar.iso_days_to_day_of_week(iso_days)

    if last_day <= day_of_week do
      iso_days - (day_of_week - last_day) + days_in_week()
    else
      iso_days - (day_of_week - last_day)
    end
  end

  def long_year?(year, %Config{} = config) do
    first_day = first_gregorian_day_of_year(year, config)
    last_day = last_gregorian_day_of_year(year, config)
    days_in_year = last_day - first_day + 1
    div(days_in_year, days_in_week()) == @weeks_in_long_year
  end

  def date_to_iso_days(year, week, day, config) do
    {days, _day_fraction} = naive_datetime_to_iso_days(year, week, day, 0, 0, 0, {0, 6}, config)
    days
  end

  def date_from_iso_days(iso_day_number, config) do
    {year, week, day, _, _, _, _} = naive_datetime_from_iso_days({iso_day_number, {0, 6}}, config)
    {year, week, day}
  end

  def date_to_string(year, week, day) do
    "#{year}-W#{lpad(week)}-#{day}"
  end

  def naive_datetime_from_iso_days({days, day_fraction}, config) do
    {year, _month, _day} = Calendar.ISO.date_from_iso_days(days)
    first_day = first_gregorian_day_of_year(year, config)

    {year, first_day} =
      cond do
        first_day > days ->
          {year - 1, first_gregorian_day_of_year(year - 1, config)}

        days - first_day + 1 > config.calendar.days_in_year(year) ->
          {year + 1, first_gregorian_day_of_year(year + 1, config)}

        true ->
          {year, first_day}
      end

    day_of_year = days - first_day + 1
    week = trunc(Float.ceil(day_of_year / days_in_week()))
    day = day_of_year - (week - 1) * days_in_week()

    {hour, minute, second, microsecond} = Calendar.ISO.time_from_day_fraction(day_fraction)
    {year, week, day, hour, minute, second, microsecond}
  end

  def naive_datetime_to_iso_days(year, week, day, hour, minute, second, microsecond, config) do
    days = first_gregorian_day_of_year(year, config) + week_to_days(week) + day - 1
    day_fraction = Calendar.ISO.time_to_day_fraction(hour, minute, second, microsecond)
    {days, day_fraction}
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

  def naive_datetime_to_string(
        year,
        month,
        day,
        hour,
        minute,
        second,
        microsecond
      ) do
    date_to_string(year, month, day) <>
      " " <>
      Calendar.ISO.time_to_string(hour, minute, second, microsecond)
  end

  defp lpad(week) when week < 10 do
    "0#{week}"
  end

  defp lpad(week) do
    week
  end

  defp week_to_days(week) do
    (week - 1) * days_in_week()
  end

  defp long_year_inc(year, @months_in_year, config) do
    if long_year?(year, config), do: 1, else: 0
  end

  defp long_year_inc(_year, _month, _config) do
    0
  end
end
