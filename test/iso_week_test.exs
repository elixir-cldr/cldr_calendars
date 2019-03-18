defmodule Cldr.Calendar.ISOWeek.Test do
  use ExUnit.Case

  test "that Cldr.Calendar.ISOWeek dates all round trip" do
    for year <- 0001..2200,
        week <- 1..Cldr.Calendar.ISOWeek.weeks_in_year(year),
        day <- 1..7 do
      {:ok, wk} = Date.new(year, week, day, Cldr.Calendar.ISOWeek)
      {:ok, iso} = Date.convert(wk, Calendar.ISO)
      {:ok, converted} = Date.convert(iso, Cldr.Calendar.ISOWeek)
      assert Date.compare(wk, converted) == :eq
    end
  end
end