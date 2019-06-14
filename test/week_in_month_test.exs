defmodule Cldr.Calendar.WeekInMonth.Test do
  use ExUnit.Case, async: true
  import Cldr.Calendar.Sigils

  test "Week in month for gregorian dates with ISO Week configuration" do
    assert Cldr.Calendar.week_of_month(~D[2019-01-01]) == {1, 1}

    # The Gregorian calendar has an ISO Week week configuration
    # So this gregorian date is actually in the next year, first month
    assert Cldr.Calendar.week_of_month(~D[2018-12-31]) == {1, 1}
    assert Cldr.Calendar.week_of_month(~D[2019-12-30]) == {1, 1}

    assert Cldr.Calendar.week_of_month(~D[2019-12-28]) == {12, 4}
  end

  test "Week in month for gregorian dates with first week starting on January 1st" do
    assert Cldr.Calendar.week_of_month(~d[2019-01-01 BasicWeek]) == {1, 1}
    assert Cldr.Calendar.week_of_month(~d[2018-12-31 BasicWeek]) == {12, 5}
    assert Cldr.Calendar.week_of_month(~d[2019-12-30 BasicWeek]) == {12, 5}
    assert Cldr.Calendar.week_of_month(~d[2019-12-28 BasicWeek]) == {12, 4}

    assert Cldr.Calendar.week_of_month(~d[2019-04-01 BasicWeek]) == {4, 1}
    assert Cldr.Calendar.week_of_month(~d[2019-04-07 BasicWeek]) == {4, 1}
    assert Cldr.Calendar.week_of_month(~d[2019-04-08 BasicWeek]) == {4, 2}
  end

  test "Week in month for ISOWeek which has a 4-4-5 configuration" do
    assert Cldr.Calendar.week_of_month(~d[2019-W01-1 ISOWeek]) == {1, 1}
    assert Cldr.Calendar.week_of_month(~d[2018-W04-1 ISOWeek]) == {1, 4}
    assert Cldr.Calendar.week_of_month(~d[2019-W05-1 ISOWeek]) == {2, 1}
    assert Cldr.Calendar.week_of_month(~d[2019-W12-1 ISOWeek]) == {3, 3}
    assert Cldr.Calendar.week_of_month(~d[2019-W13-1 ISOWeek]) == {3, 4}
    assert Cldr.Calendar.week_of_month(~d[2019-W14-1 ISOWeek]) == {4, 1}
  end
end
