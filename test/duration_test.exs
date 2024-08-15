defmodule Cldr.Calendar.Duration.Test do
  use ExUnit.Case, async: true
  alias Cldr.Calendar.Duration
  import Cldr.Calendar.Helper

  test "date durations" do
    assert Cldr.Calendar.Duration.date_duration(~D[1999-02-03], ~D[2000-12-01]) ==
             %Cldr.Calendar.Duration{
               day: 26,
               hour: 0,
               microsecond: {0, 6},
               minute: 0,
               month: 9,
               second: 0,
               year: 1
             }

    assert Cldr.Calendar.plus(~D[1999-02-03], %Cldr.Calendar.Duration{
             day: 26,
             hour: 0,
             microsecond: {0, 6},
             minute: 0,
             month: 9,
             second: 0,
             year: 1
           }) == ~D[2000-12-01]

    assert Cldr.Calendar.Duration.date_duration(~D"1984-02-14", ~D"2008-08-20") ==
             %Cldr.Calendar.Duration{
               day: 6,
               hour: 0,
               microsecond: {0, 6},
               minute: 0,
               month: 6,
               second: 0,
               year: 24
             }

    assert Cldr.Calendar.plus(~D"1984-02-14", %Cldr.Calendar.Duration{
             day: 6,
             hour: 0,
             microsecond: {0, 6},
             minute: 0,
             month: 6,
             second: 0,
             year: 24
           }) == ~D"2008-08-20"

    assert Cldr.Calendar.Duration.date_duration(~D"1960-06-14", ~D"2008-07-14") ==
             %Cldr.Calendar.Duration{
               day: 0,
               hour: 0,
               microsecond: {0, 6},
               minute: 0,
               month: 1,
               second: 0,
               year: 48
             }

    assert Cldr.Calendar.plus(~D"1960-06-14", %Cldr.Calendar.Duration{
             day: 0,
             hour: 0,
             microsecond: {0, 6},
             minute: 0,
             month: 1,
             second: 0,
             year: 48
           }) == ~D"2008-07-14"

    assert Cldr.Calendar.Duration.date_duration(~D"1960-05-05", ~D"2008-07-13") ==
             %Cldr.Calendar.Duration{
               day: 8,
               hour: 0,
               microsecond: {0, 6},
               minute: 0,
               month: 2,
               second: 0,
               year: 48
             }

    assert Cldr.Calendar.plus(~D"1960-05-05", %Cldr.Calendar.Duration{
             day: 8,
             hour: 0,
             microsecond: {0, 6},
             minute: 0,
             month: 2,
             second: 0,
             year: 48
           }) == ~D"2008-07-13"
  end

  test "datetime duration full year" do
    assert Duration.new(~D[2019-01-01], ~D[2019-12-31]) ==
             {:ok,
              %Duration{
                year: 0,
                month: 11,
                day: 30,
                hour: 0,
                microsecond: {0, 6},
                minute: 0,
                second: 0
              }}
  end

  test "datetime duration one day crossing month boundary" do
    assert Duration.new(~D[2019-01-31], ~D[2019-02-01]) ==
             {:ok,
              %Duration{
                year: 0,
                month: 0,
                day: 1,
                hour: 0,
                microsecond: {0, 6},
                minute: 0,
                second: 0
              }}
  end

  test "datetime one day crossing year boundary" do
    assert Duration.new(~D[2019-12-31], ~D[2020-01-01]) ==
             {:ok,
              %Duration{
                year: 0,
                month: 0,
                day: 1,
                hour: 0,
                microsecond: {0, 6},
                minute: 0,
                second: 0
              }}
  end

  test "datetime duration month and day incremented" do
    assert Duration.new(~D[2019-05-27], ~D[2019-08-30]) ==
             {:ok,
              %Duration{
                year: 0,
                month: 3,
                day: 3,
                hour: 0,
                microsecond: {0, 6},
                minute: 0,
                second: 0
              }}
  end

  test "datetime duration month and day also incremented to last day of year" do
    assert Duration.new(~D[2000-05-01], ~D[2019-12-31]) ==
             {:ok,
              %Duration{
                year: 19,
                month: 7,
                day: 30,
                hour: 0,
                microsecond: {0, 6},
                minute: 0,
                second: 0
              }}
  end

  test "datetime duration of two months across a year boundary" do
    assert Duration.new(~D[2000-12-01], ~D[2019-01-31]) ==
             {:ok,
              %Duration{
                year: 18,
                month: 1,
                day: 30,
                hour: 0,
                microsecond: {0, 6},
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
                microsecond: {0, 6},
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
              %Duration{
                year: 18,
                month: 1,
                day: 6,
                hour: 0,
                microsecond: {0, 6},
                minute: 0,
                second: 0
              }}
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
                microsecond: {0, 6},
                minute: 0,
                second: 0
              }}
  end

  if Code.ensure_loaded?(Cldr.List) do
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
  else
    test "duration to_string" do
      {:ok, duration} = Duration.new(~D[2019-01-01], ~D[2019-12-31])

      assert to_string(duration) ==
               "11 months, 30 days"

      assert Cldr.Calendar.Duration.to_string(duration, style: :narrow) ==
               {:ok, "11 months, 30 days"}

      assert Cldr.Calendar.Duration.to_string(duration,
               style: :narrow,
               list_options: [style: :unit_narrow]
             ) ==
               {:ok, "11 months, 30 days"}
    end
  end

  test "incompatible calendars" do
    from = ~D[2019-01-01]
    to = ~D[2019-12-31] |> Map.put(:calendar, Cldr.Calendar.Gregorian)

    assert Duration.new(from, to) ==
             {:error,
              {Cldr.IncompatibleCalendarError,
               "The two dates must be in the same calendar. Found #{inspect(from)} and #{inspect(to)}"}}
  end

  test "incompatible time zones" do
    {:ok, from} = ~U[2020-01-01 00:00:00.0Z] |> DateTime.from_naive("Etc/UTC")
    {:ok, to} = ~U[2020-01-01 00:00:00.0Z] |> DateTime.from_naive("Australia/Sydney")

    assert Duration.new(from, to) ==
             {:error,
              {Cldr.IncompatibleTimeZone,
               "`from` and `to` must be in the same time zone. " <>
                 "Found ~U[2020-01-01 00:00:00.0Z] and #DateTime<2020-01-01 00:00:00.0+11:00 AEDT Australia/Sydney>"}}
  end

  test "duration with positive time difference no date difference" do
    assert Cldr.Calendar.Duration.new(~U[2020-01-01 00:00:00.0Z], ~U[2020-01-01 01:00:00.0Z]) ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 0,
                hour: 1,
                microsecond: {0, 6},
                minute: 0,
                month: 0,
                second: 0,
                year: 0
              }}

    assert Cldr.Calendar.Duration.new(~U[2020-01-01 00:00:00.0Z], ~U[2020-01-01 01:02:00.0Z]) ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 0,
                hour: 1,
                microsecond: {0, 6},
                minute: 2,
                month: 0,
                second: 0,
                year: 0
              }}

    assert Cldr.Calendar.Duration.new(~U[2020-01-01 00:00:00.0Z], ~U[2020-01-01 01:02:03.0Z]) ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 0,
                hour: 1,
                microsecond: {0, 6},
                minute: 2,
                month: 0,
                second: 3,
                year: 0
              }}

    assert Cldr.Calendar.Duration.new(~U[2020-01-01 00:00:00.0Z], ~U[2020-01-01 01:02:03.4Z])

    {:ok,
     %Cldr.Calendar.Duration{
       day: 0,
       hour: 1,
       microsecond: 400_000,
       minute: 2,
       month: 0,
       second: 3,
       year: 0
     }}
  end

  test "duration with negative time difference" do
    assert Cldr.Calendar.Duration.new(~U[2020-01-01 02:00:00.0Z], ~U[2020-01-02 01:00:00.0Z]) ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 0,
                hour: 23,
                microsecond: {0, 6},
                minute: 0,
                month: 0,
                second: 0,
                year: 0
              }}

    assert Cldr.Calendar.Duration.new(~U[2020-01-01 02:02:00.0Z], ~U[2020-01-02 01:00:00.0Z]) ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 0,
                hour: 22,
                microsecond: {0, 6},
                minute: 58,
                month: 0,
                second: 0,
                year: 0
              }}

    assert Cldr.Calendar.Duration.new(~U[2020-01-01 02:02:02.0Z], ~U[2020-01-02 01:00:00.0Z]) ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 0,
                hour: 22,
                microsecond: {0, 6},
                minute: 57,
                month: 0,
                second: 58,
                year: 0
              }}

    assert Cldr.Calendar.Duration.new(~U[2020-01-01 02:03:04.0Z], ~U[2020-01-02 01:00:00.0Z]) ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 0,
                hour: 22,
                microsecond: {0, 6},
                minute: 56,
                month: 0,
                second: 56,
                year: 0
              }}
  end

  test "duration from date range" do
    assert Cldr.Calendar.Duration.new(Date.range(~D[2020-01-01], ~D[2020-12-31])) ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 30,
                hour: 0,
                microsecond: {0, 6},
                minute: 0,
                month: 11,
                second: 0,
                year: 0
              }}
  end

  test "duration from CalendarInterval" do
    use CalendarInterval

    assert Cldr.Calendar.Duration.new(~I"2020-01/12") ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 30,
                hour: 0,
                microsecond: {0, 6},
                minute: 0,
                month: 11,
                second: 0,
                year: 0
              }}
  end

  test "time duration" do
    assert Cldr.Calendar.Duration.new(~T[00:00:59], ~T[00:01:23]) ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 0,
                hour: 0,
                microsecond: {0, 6},
                minute: 0,
                month: 0,
                second: 24,
                year: 0
              }}
  end

  test "creating a negative time duration" do
    assert Cldr.Calendar.Duration.new(~T[10:00:00.0], ~T[09:00:00.0]) ==
             {:ok,
              %Cldr.Calendar.Duration{
                day: 0,
                hour: -1,
                microsecond: {0, 6},
                minute: 0,
                month: 0,
                second: 0,
                year: 0
              }}
  end
end
