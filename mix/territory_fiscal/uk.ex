require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.UK do
  use Cldr.Calendar.Base.Month,
    first_or_last: :first,
    first_month_of_year: 4,
    year: :majority
end
