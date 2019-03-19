defmodule Cldr.Calendar.Ends.Test do
  use ExUnit.Case

  test "that anchor: :last returns the last day of year for a range of days of the week" do
    days = %{
      {2019, 7, 25} => 4,
      {2019, 7, 26} => 5,
      {2019, 7, 27} => 6,
      {2019, 7, 28} => 7,
      {2019, 7, 29} => 1,
      {2019, 7, 30} => 2,
      {2019, 7, 31} => 3,
      {2000, 7, 27} => 4,
      {2000, 7, 28} => 5,
      {2000, 7, 29} => 6,
      {2000, 7, 30} => 7,
      {2000, 7, 31} => 1,
      {2000, 7, 25} => 2,
      {2000, 7, 26} => 3,
      {1954, 7, 25} => 7,
      {1954, 7, 26} => 1,
      {1954, 7, 27} => 2,
      {1954, 7, 28} => 3,
      {1954, 7, 29} => 4,
      {1954, 7, 30} => 5,
      {1954, 7, 31} => 6,
      {1949, 7, 25} => 1,
      {1949, 7, 26} => 2,
      {1949, 7, 27} => 3,
      {1949, 7, 28} => 4,
      {1949, 7, 29} => 5,
      {1949, 7, 30} => 6,
      {1949, 7, 31} => 7
    }

    config = %Cldr.Calendar.Config{
      anchor: :last,
      min_days: 7,
      year: :beginning,
      month: 7,
      day: 6
    }

    for {expected_date, day_of_week} <- days do
      config = Map.put(config, :day, day_of_week)
      {year, _, _} = expected_date
      last_day = Cldr.Calendar.Base.Week.last_day_of_year(year, config)
      calculated_date = Calendar.ISO.date_from_iso_days(last_day)
      assert expected_date == calculated_date
    end
  end

  # Examples from https://en.wikipedia.org/wiki/4–4–5_calendar
  test "the last day of year for last Saturday in August" do
    days = [
      {2014, 8, 30},
      {2015, 8, 29},
      {2016, 8, 27},
      {2017, 8, 26},
      {2018, 8, 25},
      {2019, 8, 31},
      {2020, 8, 29},
      {2021, 8, 28},
      {2022, 8, 27},
      {2023, 8, 26},
      {2024, 8, 31},
      {2025, 8, 30},
      {2026, 8, 29},
      {2027, 8, 28},
      {2028, 8, 26},
      {2029, 8, 25}
    ]

    config = %Cldr.Calendar.Config{
      anchor: :last,
      day: 6,
      min_days: 7,
      month: 8
    }

    for {date} <- days do
      {year, _, _} = date
      last_day = Cldr.Calendar.Base.Week.last_day_of_year(year, config)
      last_date = Calendar.ISO.date_from_iso_days(last_day)
      assert last_date == date
    end
  end

  test "that anchor: :last returns the first day of year for a set of years" do
    days = %{
      2019 => {2018, 7, 29},
      2000 => {1999, 8, 1}
    }

    config = %Cldr.Calendar.Config{
      anchor: :last,
      day: 6,
      min_days: 7,
      month: 7,
      year: :beginning
    }

    for {year, date} <- days do
      first_day = Cldr.Calendar.Base.Week.first_day_of_year(year, config)
      first_date = Calendar.ISO.date_from_iso_days(first_day)
      assert first_date == date
    end
  end
end
