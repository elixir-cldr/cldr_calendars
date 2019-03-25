defmodule Cldr.Calendar.NRF.Test do
  use ExUnit.Case

  test "correct NRF start and end dates for several years" do
    nrf_years = %{
      2016 => [{2016, 1, 31}, {2017, 1, 28}],
      2017 => [{2017, 1, 29}, {2018, 2, 3}],
      2018 => [{2018, 2, 4}, {2019, 2, 2}],
      2019 => [{2019, 2, 3}, {2020, 2, 1}],
      2020 => [{2020, 2, 2}, {2021, 1, 30}],
      2021 => [{2021, 1, 31}, {2022, 1, 29}],
      2022 => [{2022, 1, 30}, {2023, 1, 28}],
      2023 => [{2023, 1, 29}, {2024, 2, 3}],
    }

    for {year, [starts, ends]} <- nrf_years do
      assert  Calendar.ISO.date_from_iso_days(Cldr.Calendar.NRF.first_gregorian_day_of_year(year)) == starts
      assert  Calendar.ISO.date_from_iso_days(Cldr.Calendar.NRF.last_gregorian_day_of_year(year)) == ends
    end
  end

  test "NRF leap years" do
    assert Cldr.Calendar.NRF.leap_year?(2017) == true
    assert Cldr.Calendar.NRF.leap_year?(2023) == true
    assert Cldr.Calendar.NRF.leap_year?(2022) == false
  end
end