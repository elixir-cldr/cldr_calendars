defmodule Cldr.Calendar.Gregorian do
  @behaviour Calendar
  @behaviour Cldr.Calendar

  alias Calendar.ISO

  @first_day_of_week 1
  @min_days_in_first_week 4
  @days_in_week 7
  @months_in_quarter 3

  def week_of_year(year, month, day) do
    iso_days = ISO.date_to_iso_days(year, month, day)
    first_week_starts = first_week_starts(year)
    last_week_ends = last_week_ends(year)

    cond do
      iso_days < first_week_starts ->
        if long_year?(year - 1), do: {year - 1, 53}, else: {year - 1, 52}
      iso_days > last_week_ends ->
        {year + 1, 1}
      true ->
        week = div(iso_days - first_week_starts, @days_in_week) + 1
        {year, week}
    end
  end

  def long_year?(year) do
    div(last_week_ends(year) - first_week_starts(year) + 1, @days_in_week) == 53
  end

  def days_in_year(year) do
    if leap_year?(year), do: 365, else: 366
  end

  def day_name(year, month, day, options \\ []) do
    with {format, locale, backend} <- extract_options(options) do
      day = day_of_week(year, month, day)
      get_in(backend.day(locale), [:format, format, day_code(day)])
    end
  end

  def month_name(_year, month, _day, options \\ []) do
    with {format, locale, backend} <- extract_options(options) do
      get_in(backend.month(locale), [:format, format, month])
    end
  end

  def quarter_name(_year, month, _day, options \\ []) do
    with {format, locale, backend} <- extract_options(options) do
      quarter =  div(month - 1, @months_in_quarter) + 1
      get_in(backend.quarter(locale), [:format, format, quarter])
    end
  end

  def era_name(year, _month, _day, options \\ []) do
    with {format, locale, backend} <- extract_options(options) do
      {_year, era} = year_of_era(year)
      get_in(backend.era(locale), [:format, format, era])
    end
  end

  def first_day_of_week do
    @first_day_of_week
  end

  def min_days_in_first_week do
    @min_days_in_first_week
  end

  defdelegate date_to_string(year, month, day), to: Calendar.ISO
  defdelegate datetime_to_string(year, month, day, hour, minute, second, microsecond, time_zone, zone_abbr, utc_offset, std_offset), to: Calendar.ISO
  defdelegate day_of_era(year, month, day), to: Calendar.ISO
  defdelegate day_of_week(year, month, day), to: Calendar.ISO
  defdelegate day_of_year(year, month, day), to: Calendar.ISO
  defdelegate day_rollover_relative_to_midnight_utc, to: Calendar.ISO
  defdelegate days_in_month(year, month), to: Calendar.ISO
  defdelegate leap_year?(year), to: Calendar.ISO
  defdelegate months_in_year(year), to: Calendar.ISO
  defdelegate naive_datetime_from_iso_days(iso_days), to: Calendar.ISO
  defdelegate naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond), to: Calendar.ISO
  defdelegate naive_datetime_to_string(year, month, day, hour, minute, second, microsecond), to: Calendar. ISO
  defdelegate quarter_of_year(year, month, day), to: Calendar.ISO
  defdelegate time_from_day_fraction(day_fraction), to: Calendar.ISO
  defdelegate time_to_day_fraction(hour, minute, second, microsecond), to: Calendar.ISO
  defdelegate time_to_string(hour, minute, second, microsecond), to: Calendar.ISO
  defdelegate valid_date?(year, month, day), to: Calendar.ISO
  defdelegate valid_time?(hour, minute, second, microsecond), to: Calendar.ISO
  defdelegate year_of_era(year), to: Calendar.ISO

  defp first_week_starts(year) do
    iso_days = ISO.date_to_iso_days(year, 1, @min_days_in_first_week)
    day_of_week = Cldr.Calendar.iso_days_to_day_of_week(iso_days)

    if @first_day_of_week < day_of_week do
      iso_days - (day_of_week - @first_day_of_week)
    else
      iso_days + (day_of_week - @first_day_of_week)
    end
  end

  defp last_week_ends(year) do
    iso_days = ISO.date_to_iso_days(year, 12, 31 - @min_days_in_first_week + 1)
    day_of_week = Cldr.Calendar.iso_days_to_day_of_week(iso_days)

    last_week_starts =
      if @first_day_of_week < day_of_week do
        iso_days - (day_of_week - @first_day_of_week + 1)
      else
        iso_days + (day_of_week - @first_day_of_week + 1)
      end

    last_week_starts + @days_in_week
  end

  defp extract_options(options) do
    backend = Keyword.get(options, :backend)
    locale = Keyword.get(options, :locale, Cldr.get_locale())

    with {:ok, locale} <- Cldr.validate_locale(locale, backend) do
      format = Keyword.get(options, :format, :wide)
      module = Module.concat(backend, Calendar.Data)
      {format, locale, module}
    end
  end

  defp day_code(1), do: :mon
  defp day_code(2), do: :tue
  defp day_code(3), do: :wed
  defp day_code(4), do: :thu
  defp day_code(5), do: :fri
  defp day_code(6), do: :sat
  defp day_code(7), do: :sun
end