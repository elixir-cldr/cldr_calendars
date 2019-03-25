require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.Gregorian do
  use Cldr.Calendar.Base.Month,
    month: 1,
    min_days: 4,
    first_day: 1
end
