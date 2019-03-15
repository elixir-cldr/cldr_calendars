require Cldr.Calendar.Backend.Compiler

defmodule Cldr.Calendar.ISO do
  use Cldr.Calendar.Week,
    first_day: 1,
    min_days: 4
end