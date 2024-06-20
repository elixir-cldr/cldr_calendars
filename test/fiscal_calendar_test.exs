defmodule Cldr.Calendar.FiscalCalendar.Test do
  use ExUnit.Case, async: true

  test "creation of a fiscal calendar" do
    assert {_, Cldr.Calendar.FiscalYear.US} = Cldr.Calendar.FiscalYear.calendar_for(:US)

    assert Cldr.Calendar.FiscalYear.calendar_for(:XT) ==
             {:error, {Cldr.UnknownTerritoryError, "The territory :XT is unknown"}}
  end

  test "US Fiscal dates" do
    {_, us} = Cldr.Calendar.FiscalYear.calendar_for(:US)
    year = us.year(2021)

    assert Date.convert!(year.first, Cldr.Calendar.Gregorian) ==
             ~D[2020-10-01 Cldr.Calendar.Gregorian]

    assert Date.convert!(year.last, Cldr.Calendar.Gregorian) ==
             ~D[2021-09-30 Cldr.Calendar.Gregorian]
  end

  test "AU Fiscal dates" do
    {:ok, au} = Cldr.Calendar.FiscalYear.calendar_for(:AU)
    year = au.year(2022)

    assert Date.convert!(year.first, Cldr.Calendar.Gregorian) ==
             ~D[2021-07-01 Cldr.Calendar.Gregorian]

    assert Date.convert!(year.last, Cldr.Calendar.Gregorian) ==
             ~D[2022-06-30 Cldr.Calendar.Gregorian]
  end
end
