require Cldr.Calendar.Compiler.Month

# A week that starts on day one of the year
defmodule Cldr.Calendar.BasicWeek do
  use Cldr.Calendar.Base.Month, first_day_of_year: :first
end
