defmodule Cldr.Calendar.Sigils do
  def sigil_d(date, []) do
    with {:ok, date} <- Date.from_iso8601(date, Cldr.Calendar.Gregorian) do
      date
    end
  end

  def sigil_d(date, calendar) do
    calendar = Module.concat(Cldr.Calendar, List.to_string(calendar))
    with {:ok, date} <- Date.from_iso8601(date, calendar) do
      date
    end
  end
end
