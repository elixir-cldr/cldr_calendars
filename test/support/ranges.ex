defmodule Cldr.Calendar.Range do
  defmodule Feb do
    use Cldr.Calendar.Base.Month,
      month: 2
  end

  defmodule Jan do
    use Cldr.Calendar.Base.Month,
      month: 1
  end

  def daterange_periods(calendar \\ Cldr.Calendar.Range.Feb) do
    {:ok, today} = Date.convert(Date.utc_today(), calendar)
    this_week = Cldr.Calendar.week(today)
    this_month = Cldr.Calendar.month(today)
    this_year = Cldr.Calendar.year(today)
    last_week_day = Cldr.Calendar.previous(today, :week)
    last_month_day = Cldr.Calendar.previous(today, :month)
    last_year_day = Cldr.Calendar.previous(today, :year)
    last_week = Cldr.Calendar.week(last_week_day)
    last_month = Cldr.Calendar.month(last_month_day)
    last_year = Cldr.Calendar.year(last_year_day)

    %{
      "This week" => [this_week.first, this_week.last],
      "Last week" => [last_week.first, last_week.last],
      "This month" => [this_month.first, this_month.last],
      "Last month" => [last_month.first, last_month.last],
      "This year" => [this_year.first, this_year.last],
      "Last year" => [last_year.first, last_year.last]
    }
  end
end
