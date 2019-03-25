defmodule Cldr.Calendar.Sigils do
  def sigil_d(date, []) do
    with {:ok, date} <- Date.from_iso8601(date, Cldr.Calendar.Gregorian) do
      date
    end
  end

  def sigil_d(date, calendar) do
    calendar = Module.concat(Cldr.Calendar, List.to_string(calendar))
    [year, month, day] =
      date
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    with {:ok, date} <- Date.new(year, month, day, calendar) do
      date
    end
  end
end
