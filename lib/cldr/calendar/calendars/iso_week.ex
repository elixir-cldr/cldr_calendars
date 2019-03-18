require Cldr.Calendar.Compiler.Week

defmodule Cldr.Calendar.ISOWeek do
  use Cldr.Calendar.Base.Week,
    day: 1,
    min_days: 4

end