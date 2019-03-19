require Cldr.Calendar.Compiler.Week

defmodule Cldr.Calendar.CSCO do
  use Cldr.Calendar.Base.Week,
    min_days: 5,
    anchor: :last,
    day: 6,
    month: 7
end
