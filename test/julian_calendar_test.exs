defmodule Cldr.Calendar.Julian.Test do
  use ExUnit.Case, async: true
  import Cldr.Calendar.Helper

  test "that we can localize a julian date" do
    assert Cldr.Calendar.localize(date(2019, 03, 01, Cldr.Calendar.Julian), :era) == "AD"
  end

  test "plus years in a Julian date" do
    assert Cldr.Calendar.Julian.plus(1, 1, 1, :years, 1)
  end

  test "Calendar conversion from Julian starting March 25 for dates before new year" do
    assert {:ok, ~D[1751-01-12 Cldr.Calendar.Gregorian]} ==
             Date.convert(~D[1750-01-01 Cldr.Calendar.Julian.March25], Cldr.Calendar.Gregorian)
  end

  test "Calendar conversion from Julian starting March 25 for dates after new year" do
    assert {:ok, ~D[1751-04-05 Cldr.Calendar.Gregorian]} ==
             Date.convert(~D[1751-03-25 Cldr.Calendar.Julian.March25], Cldr.Calendar.Gregorian)
  end

  test "Calendar conversion to Julian starting March 25 for dates before new year" do
    assert {:ok, ~D[1750-01-01 Cldr.Calendar.Julian.March25]} ==
             Date.convert(~D[1751-01-12 Cldr.Calendar.Gregorian], Cldr.Calendar.Julian.March25)
  end

  test "Calendar conversion to Julian starting March 25 for dates after new year" do
    assert {:ok, ~D[1751-03-25 Cldr.Calendar.Julian.March25]} ==
             Date.convert(~D[1751-04-05 Cldr.Calendar.Gregorian], Cldr.Calendar.Julian.March25)
  end
end
