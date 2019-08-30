defmodule Cldr.Calendar.Duration do
  @struct_list [year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, microsecond: 0]
  @keys Keyword.keys(@struct_list)
  defstruct @struct_list

  @microseconds_in_second 1_000_000
  @microseconds_in_day 86_400_000_000

  defimpl String.Chars do
    def to_string(duration) do
      Cldr.Calendar.Duration.to_string(duration)
    end
  end

  if Code.ensure_loaded?(Cldr.Unit) do
    def to_string(%__MODULE__{} = duration, options \\ []) do
      {except, options} = Keyword.pop(options, :except, [])
      for key <- @keys, value = Map.get(duration, key), value != 0 && key not in except do
        Cldr.Unit.new(key, value)
      end
      |> Cldr.Unit.to_string(options)
    end
  else
    def to_string(%__MODULE__{} = duration, options \\ []) do
      except = Keyword.get(options, :except, [])
      for key <- @keys, value = Map.get(duration, key), value != 0 && key not in except do
        if value > 1, do: "#{value} #{key}s", else: "#{value} #{key}"
      end
      |> Enum.join(", ")
    end
  end

  def duration(%{calendar: calendar} = from, %{calendar: calendar} = to) do
    time_diff = time_duration(from, to)
    date_diff = date_duration(from, to)

    if time_diff < 0 do
      back_one_day(date_diff, calendar) |> merge(@microseconds_in_day + time_diff)
    else
      date_diff |> merge(time_diff)
    end
  end

  def time_duration(%{hour: _, minute: _, second: _, microsecond: _, calendar: calendar} = from,
      %{hour: _, minute: _, second: _, microsecond: _, calendar: calendar} = to) do
    Time.diff(to, from, :microsecond)
  end

  def time_duration(_to, _from) do
    0
  end

  def date_duration(%{year: year, month: month, day: day, calendar: calendar},
        %{year: year, month: month, day: day, calendar: calendar}) do
    %__MODULE__{}
  end

  def date_duration(%{calendar: calendar} = from, %{calendar: calendar} = to) do
    if Date.compare(from, to) in [:gt] do
      raise ArgumentError, "`from` date must be before or equal to `to` date"
    end

    %{year: year1, month: month1, day: day1} = from
    %{year: year2, month: month2, day: day2} = to

    # Doesnt account for era in calendars like Japanese
    year_diff =
      year2 - year1 - possible_adjustment(month2, month1, day2, day1)

    month_diff =
      if month2 > month1 do
        month2 - month1 - possible_adjustment(day2, day1)
      else
        calendar.months_in_year(year1) - month1 + month2 - possible_adjustment(day2, day1)
      end

    day_diff =
      if day2 > day1 do
        day2 - day1
      else
        calendar.days_in_month(year1, month1) - day1 + day2
      end

    %__MODULE__{year: year_diff, month: month_diff, day: day_diff}
  end

  def back_one_day(date_diff, calendar) do
    back_one_day(date_diff, :day, calendar)
  end

  def back_one_day(%{day: day} = date_diff, :day, calendar) do
    %{date_diff | day: day - 1}
    |> back_one_day(:month, calendar)
  end

  def back_one_day(%{month: month, day: day} = date_diff, :month, calendar) when day < 1 do
    %{date_diff | month: month - 1}
    |> back_one_day(:year, calendar)
  end

  def back_one_day(%{year: _, month: _, day: _} = date_diff, :month, _calendar) do
    date_diff
  end

  def back_one_day(%{year: year, month: month} = date_diff, :year, calendar) when month < 1 do
    diff = %{date_diff | year: year - 1}
    diff = if diff.month < 1, do: %{diff | month: calendar.months_in_year(year)}, else: diff
    diff = if diff.day < 1, do: %{diff | day: calendar.days_in_month(year, diff.month)}, else: diff
    diff
  end

  def back_one_day(%{year: _, month: _, day: _} = date_diff, :year, _calendar) do
    date_diff
  end

  def merge(duration, microseconds) do
    {seconds, microseconds} = Cldr.Math.div_mod(microseconds, @microseconds_in_second)
    {hours, minutes, seconds} = :calendar.seconds_to_time(seconds)

    duration
    |> Map.put(:hour, hours)
    |> Map.put(:minute, minutes)
    |> Map.put(:second, seconds)
    |> Map.put(:microsecond, microseconds)
  end

  # The difference in years is adjusted if the
  # month of the `to` year is less than the
  # month of the `from` year
  def possible_adjustment(m2, m1, _d2, _d1) when m2 < m1, do: 1
  def possible_adjustment(m2, m2, d2, d1) when d2 < d1, do: 1
  def possible_adjustment(_m2, _m1, _d2, _d1), do: 0

  def possible_adjustment(m2, m1) when m2 < m1, do: 1
  def possible_adjustment(_m2, _m1), do: 0

end