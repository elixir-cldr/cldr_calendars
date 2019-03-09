defmodule Cldr.Calendar.Test do
  use ExUnit.Case
  doctest Cldr.Calendar
  doctest Cldr.Calendar.Kday

  for year <- 1980..2020,
      month <- 1..12,
      day <- 1..Calendar.ISO.days_in_month(year, month) do
    test "that week of year is correct for #{year}, #{month}, #{day}" do
      assert :calendar.iso_week_number({unquote(year), unquote(month), unquote(day)}) ==
        Cldr.Calendar.Gregorian.week_of_year(unquote(year), unquote(month), unquote(day))
    end
  end
end
