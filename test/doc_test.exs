defmodule Cldr.Calendar.Doc.Test do
  use ExUnit.Case

  doctest Cldr.Calendar
  doctest Cldr.Calendar.Duration
  doctest Cldr.Calendar.Interval
  doctest Cldr.Calendar.Kday
  doctest Cldr.Calendar.Preference

  doctest MyApp.Cldr.Calendar
end
