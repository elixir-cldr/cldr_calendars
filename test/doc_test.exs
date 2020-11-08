defmodule Cldr.Calendar.Doc.Test do
  use ExUnit.Case, asynch: true

  if Version.compare(System.version(), "1.10.0-dev") in [:gt, :eq] do
    doctest Cldr.Calendar
    doctest Cldr.Calendar.Duration
    doctest Cldr.Calendar.Interval
    doctest Cldr.Calendar.Kday
    doctest Cldr.Calendar.Preference
  end
end
