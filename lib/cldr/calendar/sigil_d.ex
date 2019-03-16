defmodule Cldr.Calendar.Sigils do
  def sigil_d(date, []) do
    Date.from_iso8601(date, Cldr.Calendar.Gregorian)
  end

  def sigil_d(date, calendar) do
    calendar = Module.concat(Cldr.Calendar, List.to_string(calendar))
    Date.from_iso8601(date, calendar)
  end
end
