require Cldr.Calendar.Compiler.Month

# A week that starts on day one of the year
defmodule Cldr.Calendar.BasicWeek do
  use Cldr.Calendar.Base.Month, day_of_week: 1
end
