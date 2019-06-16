require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.AU do
  use Cldr.Calendar.Base.Month, first_month_of_year: 7, year: :ending
end
