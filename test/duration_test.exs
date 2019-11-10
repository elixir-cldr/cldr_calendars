defmodule Cldr.Calendar.Duration.Test do
  use ExUnit.Case, async: true
  alias Cldr.Calendar.Duration
  import Cldr.Calendar.Helper

  test "durations" do
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

    assert Duration.new(~D[2019-01-31], ~D[2019-02-01]) ==
             {:ok,
              %Duration{year: 0, month: 0, day: 1, hour: 0, microsecond: 0, minute: 0, second: 0}}

    assert Duration.new(~D[2019-12-31], ~D[2020-01-01]) ==
             {:ok,
              %Duration{year: 0, month: 0, day: 1, hour: 0, microsecond: 0, minute: 0, second: 0}}

    assert Duration.new(~D[2019-01-31], ~D[2020-01-01]) ==
             {:ok,
              %Duration{year: 0, month: 11, day: 1, hour: 0, microsecond: 0, minute: 0, second: 0}}

    assert Duration.new(~D[2019-05-27], ~D[2019-08-30]) ==
             {:ok,
              %Duration{year: 0, month: 3, day: 3, hour: 0, microsecond: 0, minute: 0, second: 0}}

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

    assert Duration.new(
             date(2000, 12, 01, Cldr.Calendar.CSCO),
             date(2019, 01, 07, Cldr.Calendar.CSCO)
           ) ==
             {:ok,
              %Duration{year: 18, month: 1, day: 6, hour: 0, microsecond: 0, minute: 0, second: 0}}
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
