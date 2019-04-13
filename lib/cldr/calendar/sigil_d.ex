defmodule Cldr.Calendar.Sigils do
  @moduledoc false

  def sigil_d(date, []) do
    with {:ok, date} <- Date.from_iso8601(date, Cldr.Calendar.Gregorian) do
      date
    end
  end

  def sigil_d(date, calendar) do
    [year, month, day] =
      date
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    with {:ok, calendar} <- calendar_from_charlist(calendar),
         {:ok, date} <- Date.new(year, month, day, calendar) do
      date
    end
  end

  defp calendar_from_charlist(calendar) do
    calendar = List.to_string(calendar)

    inbuilt_calendar(calendar) ||
      fiscal_calendar(calendar) ||
      user_calendar(calendar) ||
      calendar_error(calendar)
  end

  defp inbuilt_calendar(calendar) do
    calendar = Module.concat(Cldr.Calendar, calendar)
    get_calendar(calendar)
  end

  defp fiscal_calendar(calendar) do
    calendar = Module.concat(Cldr.Calendar.FiscalYear, calendar)
    get_calendar(calendar)
  end

  defp user_calendar(calendar) do
    Module.concat("Elixir", calendar)
    |> get_calendar
  end

  defp get_calendar(calendar) do
    if Code.ensure_loaded?(calendar) and function_exported?(calendar, :cldr_calendar_type, 0) do
      {:ok, calendar}
    else
      nil
    end
  end

  defp calendar_error(calendar) do
    {:error, {Cldr.UnknownCalendarError, calendar}}
  end
end
