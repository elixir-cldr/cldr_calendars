require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.Fiscal.UK do
  use Cldr.Calendar.Base.Month,
    first_or_last: :first,
    month_of_year: 4,
    year: :majority
end
