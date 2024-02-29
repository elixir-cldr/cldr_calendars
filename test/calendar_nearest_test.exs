defmodule Cldr.Calendar.Nearest.Test do
  use ExUnit.Case, async: true

  # Setting min_days to 4 will deliver the
  # "nearest" result.

  # Examples from https://en.wikipedia.org/wiki/4–4–5_calendar
  test "year end on the Saturday nearest the end of August" do
    days = [
      {2014, 8, 30},
      {2015, 8, 29},
      {2016, 9, 3},
      {2017, 9, 2},
      {2018, 9, 1},
      {2019, 8, 31},
      {2020, 8, 29},
      {2021, 8, 28},
      {2022, 9, 3},
      {2023, 9, 2},
      {2024, 8, 31},
      {2025, 8, 30},
      {2026, 8, 29},
      {2027, 8, 28},
      {2028, 9, 2},
      {2029, 9, 1}
    ]

    config = %Cldr.Calendar.Config{
      first_or_last: :last,
      day_of_week: 6,
      min_days_in_first_week: 4,
      month_of_year: 8
    }

    for {date} <- days do
      {year, _, _} = date
      last_day = Cldr.Calendar.Base.Week.last_gregorian_day_of_year(year, config)
      last_date = Calendar.ISO.date_from_iso_days(last_day)
      assert last_date == date
    end
  end
end
