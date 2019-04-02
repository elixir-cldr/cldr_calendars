require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.Gregorian do
  @moduledoc """
  Implements the proleptic Gregorian calendar.

  Intended to be plug-compatible with `Calendar.ISO`
  with additional functions to support localisation,
  date ranges for `year`, `quarter`, `month` and `week`.

  When calling `Cldr.Calendar.localize/3` on a
  `Calendar.ISO`-based date, those dates are first
  moved to this calendar acting as a localisation
  proxy.

  """

  use Cldr.Calendar.Base.Month,
    month: 1,
    min_days: 4,
    day: 1
end
