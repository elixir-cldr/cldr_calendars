require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.US do
  use Cldr.Calendar.Base.Month,
    month: 10,
    min_days: 4,
    first_day: 7
end
