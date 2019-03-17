require Cldr.Calendar.Compiler.Week

defmodule Cldr.Calendar.NRF do
  use Cldr.Calendar.Base.Week,
    min_days: 5,
    anchor: :last,
    day: 7,
    month: 1
end
