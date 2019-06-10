defmodule Cldr.Calendar.WeekInMonth.Test do
  use ExUnit.Case, async: true

  # Overview of dates with a fixed week number in any year other than a
  # leap year starting on Thursday.
  # From https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_month

  # Month          Dates       Week numbers
  # January    04  11  18  25      01–04
  # February   01  08  15  22      05–08
  # March      01  08  15  22  29  09–13
  # April      05  12  19  26      14–17
  # May        03  10  17  24  31  18–22
  # June       07  14  21  28      23–26
  # July       05  12  19  26      27–30
  # August     02  09  16  23  30  31–35
  # September  06  13  20  27      36–39
  # October    04  11  18  25      40–43
  # November   01  08  15  22  29  44–48
  # December   06  13  20  27      49–52
  def not_leap_year_starting_thursday(year) do
    !Calendar.ISO.leap_year?(year) &&
    Cldr.Calendar.day_of_week(Cldr.Calendar.first_gregorian_day_of_year(year, Calendar.ISO)) != 4
  end

  test "Week in month" do
    dates = %{
      1 => [4, 11, 18, 25],
      2 => [1, 8, 15, 22],
      3 => [1, 8, 15, 22, 29],
      4 => [5, 12, 19, 26],
      5 => [3, 10, 17, 24, 31],
      6 => [7, 14, 21, 28],
      7 => [5, 12, 19, 26],
      8 => [2, 9, 16, 23],
      9 => [6, 13, 20, 27],
      10 => [4, 11, 18, 25],
      11 => [1, 8, 15, 22, 29],
      12 => [6, 13, 20, 27]
    }
    |> Enum.map(fn {month, weeks} ->
      {month, Enum.with_index(weeks, 1)}
    end)

    for year <- 2019..2019,
        not_leap_year_starting_thursday(year) do
      for {month, weeks} <- dates do
        IO.inspect weeks
        Enum.each weeks, fn {day, week_in_month} ->
          {:ok, date} = Date.new(year, month, day)
          IO.inspect date
          assert Cldr.Calendar.week_of_month(date) == {month, week_in_month}
        end
      end
    end
  end
end