require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.Fiscal.US do
  use Cldr.Calendar.Base.Month,
    month_of_year: 10,
    min_days_in_first_week: 4,
    day_of_week: 7,
    year: :majority
end
