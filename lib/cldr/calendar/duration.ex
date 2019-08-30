defmodule Cldr.Calendar.Duration do
  defstruct [:year, :month, :day]

  def duration(%{calendar: calendar} = from, %{calendar: calendar} = to) do
    if Date.compare(from, to) in [:gt] do
      raise ArgumentError, "From date must be less than or equal to to date"
    end

    %{year: year1, month: month1, day: day1} = from
    %{year: year2, month: month2, day: day2} = to

    # Doesnt account for era in calendars like Japanese
    year_diff =
      year2 - year1 - possible_adjustment(month2, month1, day2, day1)

    month_diff =
      if month2 > month1 do
        month2 - month1 - possible_adjustment(day2, day1)
      else
        calendar.months_in_year(year1) - month1 + month2 - possible_adjustment(day2, day1)
      end

    day_diff =
      if day2 > day1 do
        day2 - day1 + 1
      else
        calendar.days_in_month(year1, month1) - day1 + day2
      end

    %__MODULE__{year: year_diff, month: month_diff, day: day_diff}
  end

  # The difference in years is adjusted if the
  # month of the `to` year is less than the
  # month of the `from` year
  def possible_adjustment(m2, m1, _d2, _d1) when m2 < m1, do: 1
  def possible_adjustment(m2, m2, d2, d1) when d2 < d1, do: 1
  def possible_adjustment(_m2, _m1, _d2, _d1), do: 0

  def possible_adjustment(m2, m1) when m2 < m1, do: 1
  def possible_adjustment(_m2, _m1), do: 0

end