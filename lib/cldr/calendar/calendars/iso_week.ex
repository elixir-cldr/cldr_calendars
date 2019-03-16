require Cldr.Calendar.Compiler.Week

defmodule Cldr.Calendar.ISOWeek do
  use Cldr.Calendar.Base.Week,
    first_day: 1,
    min_days: 4

end