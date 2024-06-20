defmodule Cldr.Calendar.ShiftTest do
  use ExUnit.Case, async: true

  # Implements the same tests as for Calendar.ISO but using Cldr.Calendar.Gregorian

  test "shift_date/2" do
    assert Cldr.Calendar.Gregorian.shift_date(2024, 3, 2, Duration.new!([])) == {2024, 3, 2}
    assert Cldr.Calendar.Gregorian.shift_date(2024, 3, 2, Duration.new!(year: 1)) == {2025, 3, 2}
    assert Cldr.Calendar.Gregorian.shift_date(2024, 3, 2, Duration.new!(month: 2)) == {2024, 5, 2}
    assert Cldr.Calendar.Gregorian.shift_date(2024, 3, 2, Duration.new!(week: 3)) == {2024, 3, 23}
    assert Cldr.Calendar.Gregorian.shift_date(2024, 3, 2, Duration.new!(day: 5)) == {2024, 3, 7}

    assert Cldr.Calendar.Gregorian.shift_date(0, 1, 1, Duration.new!(month: 1)) == {0, 2, 1}
    assert Cldr.Calendar.Gregorian.shift_date(0, 1, 1, Duration.new!(year: 1)) == {1, 1, 1}

    assert Cldr.Calendar.Gregorian.shift_date(0, 1, 1, Duration.new!(year: -2, month: 2)) ==
             {-2, 3, 1}

    assert Cldr.Calendar.Gregorian.shift_date(-4, 1, 1, Duration.new!(year: -1)) == {-5, 1, 1}

    assert Cldr.Calendar.Gregorian.shift_date(
             2024,
             3,
             2,
             Duration.new!(year: 1, month: 2, week: 3, day: 5)
           ) ==
             {2025, 5, 28}

    assert Cldr.Calendar.Gregorian.shift_date(
             2024,
             3,
             2,
             Duration.new!(year: -1, month: -2, week: -3)
           ) ==
             {2022, 12, 12}

    assert Cldr.Calendar.Gregorian.shift_date(2020, 2, 28, Duration.new!(day: 1)) == {2020, 2, 29}

    assert Cldr.Calendar.Gregorian.shift_date(2020, 2, 29, Duration.new!(year: 1)) ==
             {2021, 2, 28}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 3, 31, Duration.new!(month: -1)) ==
             {2024, 2, 29}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 3, 31, Duration.new!(month: -2)) ==
             {2024, 1, 31}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 1, 31, Duration.new!(month: 1)) ==
             {2024, 2, 29}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 1, 31, Duration.new!(month: 2)) ==
             {2024, 3, 31}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 1, 31, Duration.new!(month: 3)) ==
             {2024, 4, 30}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 1, 31, Duration.new!(month: 4)) ==
             {2024, 5, 31}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 1, 31, Duration.new!(month: 5)) ==
             {2024, 6, 30}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 1, 31, Duration.new!(month: 6)) ==
             {2024, 7, 31}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 1, 31, Duration.new!(month: 7)) ==
             {2024, 8, 31}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 1, 31, Duration.new!(month: 8)) ==
             {2024, 9, 30}

    assert Cldr.Calendar.Gregorian.shift_date(2024, 1, 31, Duration.new!(month: 9)) ==
             {2024, 10, 31}
  end

  test "shift_datetime/2" do
    assert DateTime.shift(~U[2000-01-01 00:00:00Z Cldr.Calendar.Gregorian], year: 1) ==
             ~U[2001-01-01 00:00:00Z]

    assert DateTime.shift(~U[2000-01-01 00:00:00Z Cldr.Calendar.Gregorian], month: 1) ==
             ~U[2000-02-01 00:00:00Z]

    assert DateTime.shift(~U[2000-01-01 00:00:00Z Cldr.Calendar.Gregorian], month: 1, day: 28) ==
             ~U[2000-02-29 00:00:00Z]

    assert DateTime.shift(~U[2000-01-01 00:00:00Z Cldr.Calendar.Gregorian], month: 1, day: 30) ==
             ~U[2000-03-02 00:00:00Z]

    assert DateTime.shift(~U[2000-01-01 00:00:00Z Cldr.Calendar.Gregorian], month: 2, day: 29) ==
             ~U[2000-03-30 00:00:00Z]

    assert DateTime.shift(~U[2000-01-01 00:00:00Z Cldr.Calendar.Gregorian],
             microsecond: {4000, 4}
           ) ==
             ~U[2000-01-01 00:00:00.0040Z]

    assert DateTime.shift(~U[2000-02-29 00:00:00Z Cldr.Calendar.Gregorian], year: -1) ==
             ~U[1999-02-28 00:00:00Z]

    assert DateTime.shift(~U[2000-02-29 00:00:00Z Cldr.Calendar.Gregorian], month: -1) ==
             ~U[2000-01-29 00:00:00Z]

    assert DateTime.shift(~U[2000-02-29 00:00:00Z Cldr.Calendar.Gregorian], month: -1, day: -28) ==
             ~U[2000-01-01 00:00:00Z]

    assert DateTime.shift(~U[2000-02-29 00:00:00Z Cldr.Calendar.Gregorian], month: -1, day: -30) ==
             ~U[1999-12-30 00:00:00Z]

    assert DateTime.shift(~U[2000-02-29 00:00:00Z Cldr.Calendar.Gregorian], month: -1, day: -29) ==
             ~U[1999-12-31 00:00:00Z]
  end
end
