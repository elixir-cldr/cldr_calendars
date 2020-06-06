defmodule Cldr.Calendar.Duration.Test do
  use ExUnit.Case, async: true
  alias Cldr.Calendar.Duration
  import Cldr.Calendar.Helper

  test "date durations" do
    assert Cldr.Calendar.Duration.date_duration(~D[1999-02-03], ~D[2000-12-01]) ==
    %Cldr.Calendar.Duration{
      day: 26,
      hour: 0,
      microsecond: 0,
      minute: 0,
      month: 9,
      second: 0,
      year: 1
    }

    assert Cldr.Calendar.Duration.date_duration(~D"1984-02-14", ~D"2008-08-20") ==
    %Cldr.Calendar.Duration{
      day: 6,
      hour: 0,
      microsecond: 0,
      minute: 0,
      month: 6,
      second: 0,
      year: 24
    }

    assert Cldr.Calendar.Duration.date_duration(~D"1960-06-14", ~D"2008-07-14") ==
    %Cldr.Calendar.Duration{
      day: 0,
      hour: 0,
      microsecond: 0,
      minute: 0,
      month: 1,
      second: 0,
      year: 48
    }

    assert Cldr.Calendar.Duration.date_duration(~D"1960-05-05", ~D"2008-07-13") ==
    %Cldr.Calendar.Duration{
      day: 8,
      hour: 0,
      microsecond: 0,
      minute: 0,
      month: 2,
      second: 0,
      year: 48
    }
  end

  test "datetime duration full year" do
    assert Duration.new(~D[2019-01-01], ~D[2019-12-31]) ==
             {:ok,
              %Duration{
                year: 0,
                month: 11,
                day: 30,
                hour: 0,
                microsecond: 0,
                minute: 0,
                second: 0
              }}
  end

  test "datetime duration one day crossing month boundary" do
    assert Duration.new(~D[2019-01-31], ~D[2019-02-01]) ==
             {:ok,
              %Duration{year: 0, month: 0, day: 1, hour: 0, microsecond: 0, minute: 0, second: 0}}
  end

  test "datetime one day crossing year bounday" do
    assert Duration.new(~D[2019-12-31], ~D[2020-01-01]) ==
             {:ok,
              %Duration{year: 0, month: 0, day: 1, hour: 0, microsecond: 0, minute: 0, second: 0}}
  end

  test "datetime duration month and day incremented" do
    assert Duration.new(~D[2019-05-27], ~D[2019-08-30]) ==
             {:ok,
              %Duration{year: 0, month: 3, day: 3, hour: 0, microsecond: 0, minute: 0, second: 0}}
  end

  test "datetime duration month and day also incremented to last day of year" do
    assert Duration.new(~D[2000-05-01], ~D[2019-12-31]) ==
             {:ok,
              %Duration{
                year: 19,
                month: 7,
                day: 30,
                hour: 0,
                microsecond: 0,
                minute: 0,
                second: 0
              }}
  end

  test "datetime duration of two months across a year bounday" do
    assert Duration.new(~D[2000-12-01], ~D[2019-01-31]) ==
             {:ok,
              %Duration{
                year: 18,
                month: 1,
                day: 30,
                hour: 0,
                microsecond: 0,
                minute: 0,
                second: 0
              }}
  end

  test "datetime duration 19 years less one day" do
    assert Duration.new(
             date(2000, 12, 01, Cldr.Calendar.Gregorian),
             date(2019, 01, 31, Cldr.Calendar.Gregorian)
           ) ==
             {:ok,
              %Duration{
                year: 18,
                month: 1,
                day: 30,
                hour: 0,
                microsecond: 0,
                minute: 0,
                second: 0
              }}
  end

  test "datetiem duration of week-based calendar" do
    assert Duration.new(
             date(2000, 12, 01, Cldr.Calendar.CSCO),
             date(2019, 01, 07, Cldr.Calendar.CSCO)
           ) ==
             {:ok,
              %Duration{year: 18, month: 1, day: 6, hour: 0, microsecond: 0, minute: 0, second: 0}}
  end

  test "duration with the same month and day 2 later than day 1" do
    assert Duration.new(
             date(2020, 01, 01, Cldr.Calendar.Gregorian),
             date(2020, 01, 03, Cldr.Calendar.Gregorian)
           ) ==
             {:ok,
              %Duration{
                year: 0,
                month: 0,
                day: 2,
                hour: 0,
                microsecond: 0,
                minute: 0,
                second: 0
              }}
  end

  test "duration to_string" do
    {:ok, duration} = Duration.new(~D[2019-01-01], ~D[2019-12-31])

    assert to_string(duration) ==
             "11 months and 30 days"

    assert Cldr.Calendar.Duration.to_string(duration, style: :narrow) ==
             {:ok, "11m and 30d"}

    assert Cldr.Calendar.Duration.to_string(duration,
             style: :narrow,
             list_options: [style: :unit_narrow]
           ) ==
             {:ok, "11m 30d"}
  end

  test "incompatible calendars" do
    from = ~D[2019-01-01]
    to = ~D[2019-12-31] |> Map.put(:calendar, Cldr.Calendar.Gregorian)

    assert Duration.new(from, to) ==
             {:error,
              {Cldr.IncompatibleCalendarError,
               "The two dates must be in the same calendar. Found #{inspect(from)} and #{
                 inspect(to)
               }"}}
  end
end
