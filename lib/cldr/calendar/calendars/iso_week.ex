require Cldr.Calendar.Compiler.Week

defmodule Cldr.Calendar.ISOWeek do
  @moduledoc """
  Implements the ISO Week calendar.

  The ISO Week calendar manages dates
  in a `yyyy-ww-dd` format with each year
  having either 52 or 53 weeks.

  """
  use Cldr.Calendar.Base.Week,
    day: 1,
    min_days: 4
end
