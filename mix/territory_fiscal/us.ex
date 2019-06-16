require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.US do
  use Cldr.Calendar.Base.Month,
    first_month_of_year: 10,
    min_days_in_first_week: 4,
    first_day_of_year: 7,
    year: :majority
end
