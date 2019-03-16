require Cldr.Calendar.Compiler.Week

defmodule Cldr.Calendar.NRF do
  use Cldr.Calendar.Base.Week,
    first_day: 7,
    min_days: 5
end
