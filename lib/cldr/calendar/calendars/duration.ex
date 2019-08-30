defmodule Cldr.Calendar.Duration do
  defstruct year: 0,
            month: 0,
            day: 0,
            hour: 0,
            minute: 0,
            second: 0,
            microsecond: {0, 0},
            calendar: nil

  def duration(
        %{year: y1, month: m1, day: d1, hour: h1, minute: n1, second: s1, microsecond: ms1} =
          first,
        %{year: _, month: _, day: _, hour: _, minute: _, second: _, microsecond: _} = last
      ) do
    %{calendar: calendar} = first
    last = DateTime.convert!(last, calendar)
    %{year: y2, month: m2, day: d2, hour: h2, minute: n2, second: s2, microsecond: ms2} = last

    duration =
      rollover_time(h2 - h1, n2 - n1, s2 - s1, sub(ms2, ms1), calendar)
      |> Map.merge(rollover_date(y2 - y1, m2 - m1, d2 - d1, calendar))

    struct(__MODULE__, duration)
    |> Map.put(:calendar, calendar)
  end

  def duration(
        %{year: y1, month: m1, day: d1} = first,
        %{year: _y2, month: _m2, day: _d2} = last
      ) do
    %{calendar: calendar} = first
    last = Date.convert!(last, calendar)
    %{year: y2, month: m2, day: d2} = last

    duration = rollover_date(y2 - y1, m2 - m1, d2 - d1, calendar)

    struct(__MODULE__, duration)
    |> Map.put(:calendar, calendar)
  end

  def duration(
        %{hour: h1, minute: n1, second: s1, microsecond: ms1} = first,
        %{hour: h2, minute: n2, second: s2, microsecond: ms2}
      ) do
    %{calendar: calendar} = first

    duration = rollover_time(h2 - h1, n2 - n1, s2 - s1, sub(ms2, ms1), calendar)

    struct(__MODULE__, duration)
    |> Map.put(:calendar, calendar)
  end

  def rollover_time(hour, minute, 0 = second, {microsecond} = ms, _calendar)
      when microsecond < 0 do
    %{hour: hour, minute: minute, second: second, millisecond: ms}
  end

  def rollover_time(hour, 0 = minute, second, microsecond, _calendar) when second < 0 do
    %{hour: hour, minute: minute, second: second, millisecond: microsecond}
  end

  def rollover_time(hour, minute, second, microsecond, calendar) when minute < 0 do
    rollover_time(hour - 1, 0, second, microsecond, calendar)
  end

  @microseconds_in_second 1_000_000
  def rollover_time(hour, minute, second, {microsecond, precision}, calendar)
      when microsecond < 0 do
    rollover_time(
      hour,
      minute,
      second - 1,
      {@microseconds_in_second + microsecond, precision},
      calendar
    )
  end

  @seconds_in_minute 60
  def rollover_time(hour, minute, second, microsecond, calendar) when second < 0 do
    rollover_time(hour, minute - 1, @seconds_in_minute + second, microsecond, calendar)
  end

  def rollover_time(hour, minute, second, microsecond, _calendar) do
    %{hour: hour, minute: minute, second: second, millisecond: microsecond}
  end

  def rollover_date(year, 0 = month, day, _calendar) when day < 0 do
    %{year: year, month: month, day: day}
  end

  def rollover_date(year, month, day, calendar) when month < 0 do
    rollover_date(year - 1, 0, day, calendar)
  end

  def rollover_date(year, month, day, calendar) when day < 0 do
    day = calendar.days_in_month(year, month) + day
    rollover_date(year, month - 1, day, calendar)
  end

  def rollover_date(year, month, day, _calendar) do
    %{year: year, month: month, day: day}
  end

  defp sub({ms1, 0}, {ms2, 0}) do
    {ms2 - ms1, 0}
  end

  defp sub({ms1, p1}, {ms2, p2}) do
    precision = max(p1, p2)
    diff = ms2 - ms1
    {diff, precision}
  end
end
