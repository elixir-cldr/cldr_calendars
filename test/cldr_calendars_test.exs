defmodule Cldr.Calendar.Test do
  use ExUnit.Case
  doctest Cldr.Calendar
  doctest Cldr.Calendar.Kday

  # :calendar module doesn't work with year 0 or negative years
  test "that iso week of year is same as erlang" do
    for year <- 0001..2200,
        month <- 1..12,
        day <- 1..Calendar.ISO.days_in_month(year, month) do
      assert :calendar.iso_week_number({year, month, day}) ==
        Cldr.Calendar.Gregorian.iso_week_of_year(year, month, day, backend: MyApp.Cldr)
    end
  end
end
