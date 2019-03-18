require Cldr.Calendar.Compiler.Week

defmodule Cldr.Calendar.NRF do
  use Cldr.Calendar.Base.Week,
    min_days: 4,
    anchor: :last,
    day: 6,
    month: 1
end
