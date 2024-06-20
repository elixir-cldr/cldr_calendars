defmodule Cldr.Calendar.Month.Test do
  use ExUnit.Case, async: true

  test "that calendar month is converted to gregorian month" do
    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(1, 1) == 1
    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(2, 1) == 2
    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(10, 1) == 10
    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(12, 1) == 12

    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(1, 2) == 2
    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(2, 2) == 3
    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(10, 2) == 11
    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(12, 2) == 1

    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(1, 10) == 10
    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(2, 10) == 11
    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(10, 10) == 7
    assert Cldr.Calendar.Base.Month.calendar_month_to_gregorian_month(12, 10) == 9
  end

  test "days in month without year" do
    assert Cldr.Calendar.Base.Month.days_in_month(1, %{month_of_year: 1}) == 31
    assert Cldr.Calendar.Base.Month.days_in_month(12, %{month_of_year: 1}) == 31
    assert Cldr.Calendar.Base.Month.days_in_month(4, %{month_of_year: 1}) == 30
    assert Cldr.Calendar.Base.Month.days_in_month(2, %{month_of_year: 1}) == {:ambiguous, 28..29}
  end
end
