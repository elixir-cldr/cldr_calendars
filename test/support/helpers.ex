defmodule Cldr.Calendar.Helper do
  def date(year, month, day, calendar) do
    {:ok, date} = Date.new(year, month, day, calendar)
    date
  end
end
