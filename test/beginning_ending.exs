defmodule Cldr.Calendar.BeginsEnds.Test do
  use ExUnit.Case

  test "That the US fiscal calendar for fiscal year starts in prior gregorian year" do
    assert Cldr.Calendar.beginning_gregorian_year(2019, %Cldr.Calendar.Config{month: 10}) == 2018
  end

  test "That the US fiscal calendar for fiscal year ends in current gregorian year" do
    assert Cldr.Calendar.ending_gregorian_year(2019, %Cldr.Calendar.Config{month: 10}) == 2019
  end

  test "That the UK fiscal calendar for fiscal year starts in current gregorian year" do
    assert Cldr.Calendar.beginning_gregorian_year(2019, %Cldr.Calendar.Config{month: 4}) == 2019
  end

  test "That the UK fiscal calendar for fiscal year ends in next gregorian year" do
    assert Cldr.Calendar.ending_gregorian_year(2019, %Cldr.Calendar.Config{month: 4}) == 2020
  end
end