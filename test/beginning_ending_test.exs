defmodule Cldr.Calendar.BeginsEnds.Test do
  use ExUnit.Case

  test "The US fiscal calendar for fiscal year start and end years" do
    assert Cldr.Calendar.start_end_gregorian_years(2019, %Cldr.Calendar.Config{
             month_of_year: 10
           }) ==
             {2018, 2019}
  end

  test "The UK fiscal calendar for fiscal year start and end years" do
    assert Cldr.Calendar.start_end_gregorian_years(2019, %Cldr.Calendar.Config{
             month_of_year: 4
           }) ==
             {2019, 2020}
  end
end
