defmodule Cldr.Calendar.Starts.Test do
  use ExUnit.Case

  test "that anchor: :first returns the first gregorian day of year for a range of days of the week" do
    days = %{
      {2019, 2, 7} => 4,
      {2019, 2, 1} => 5,
      {2019, 2, 2} => 6,
      {2019, 2, 3} => 7,
      {2019, 2, 4} => 1,
      {2019, 2, 5} => 2,
      {2019, 2, 6} => 3,
      {2000, 2, 6} => 7,
      {2000, 2, 7} => 1,
      {2000, 2, 1} => 2,
      {2000, 2, 2} => 3,
      {2000, 2, 3} => 4,
      {2000, 2, 4} => 5,
      {2000, 2, 5} => 6,
      {1954, 2, 7} => 7,
      {1954, 2, 1} => 1,
      {1954, 2, 2} => 2,
      {1954, 2, 3} => 3,
      {1954, 2, 4} => 4,
      {1954, 2, 5} => 5,
      {1954, 2, 6} => 6,
      {1949, 2, 7} => 1,
      {1949, 2, 1} => 2,
      {1949, 2, 2} => 3,
      {1949, 2, 3} => 4,
      {1949, 2, 4} => 5,
      {1949, 2, 5} => 6,
      {1949, 2, 6} => 7
    }

    config = %Cldr.Calendar.Config{
      first_or_last: :first,
      min_days_in_first_week: 7,
      first_month_of_year: 2,
      first_day_of_year: 6
    }

    for {expected_date, day_of_week} <- days do
      config = Map.put(config, :first_day_of_year, day_of_week)
      {year, _, _} = expected_date
      last_day = Cldr.Calendar.Base.Week.first_gregorian_day_of_year(year, config)
      calculated_date = Calendar.ISO.date_from_iso_days(last_day)
      assert expected_date == calculated_date
    end
  end
end
