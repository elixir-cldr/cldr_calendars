defmodule Cldr.Calendar.Week do
  @days_in_week 7

  alias Cldr.Calendar.Config
  alias Calendar.ISO

  def week_of_year(year, month, day, %Config{} = config) do
    iso_days = ISO.date_to_iso_days(year, month, day)
    first_week_starts = first_week_starts(year, config)
    last_week_ends = last_week_ends(year, config)

    cond do
      iso_days < first_week_starts ->
        if long_year?(year - 1, config), do: {year - 1, 53}, else: {year - 1, 52}

      iso_days > last_week_ends ->
        {year + 1, 1}

      true ->
        week = div(iso_days - first_week_starts, @days_in_week) + 1
        {year, week}
    end
  end

  def first_week_starts(year, %Config{begins: :first} = config) do
    %{first_month: first_month, first_day: first_day, min_days: min_days} = config
    iso_days = ISO.date_to_iso_days(year, first_month, min_days)
    day_of_week = Cldr.Calendar.iso_days_to_day_of_week(iso_days)

    if first_day < day_of_week do
      iso_days - (day_of_week - first_day)
    else
      iso_days + (day_of_week - first_day)
    end
  end

  def last_week_ends(year, %Config{begins: :first} = config) do
    %{first_month: first_month, first_day: first_day, min_days: min_days} = config
    months_in_year = Calendar.ISO.months_in_year(year)
    last_month_of_year = Cldr.Math.amod(first_month - 1, months_in_year)
    days_in_month = Calendar.ISO.days_in_month(year, last_month_of_year)
    iso_days = ISO.date_to_iso_days(year, last_month_of_year, days_in_month - min_days + 1)
    day_of_week = Cldr.Calendar.iso_days_to_day_of_week(iso_days)

    last_week_starts =
      if first_day < day_of_week do
        iso_days - (day_of_week - first_day + 1)
      else
        iso_days + (day_of_week - first_day + 1)
      end

    last_week_starts + @days_in_week
  end

  def long_year?(year, %Config{} = config) do
    first_day = last_week_ends(year, config)
    last_day = first_week_starts(year, config)
    days_in_year = first_day - last_day + 1
    div(days_in_year, @days_in_week) == 53
  end

end