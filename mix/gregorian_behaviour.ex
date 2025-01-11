defmodule Cldr.Calendar.Behaviour.Gregorian do
  @moduledoc """
  Implementation of the Gregorian calendar used
  only to validate the calendar behaviour,

  """

  use Cldr.Calendar.Behaviour,
    epoch: ~D[0000-01-01]

  @doc """
  Returns if the given year is a leap year.

  """
  @spec leap_year?(Calendar.year()) :: boolean()
  @impl true
  def leap_year?(year) do
    Calendar.ISO.leap_year?(year)
  end

  @doc """
  Returns the number of days since the calendar
  epoch for a given `year-month-day`

  """
  def date_to_iso_days(year, month, day) do
    Calendar.ISO.date_to_iso_days(year, month, day)
  end

  @doc """
  Returns a `{year, month, day}` calculated from
  the number of `iso_days`.

  """
  def date_from_iso_days(iso_days) do
    Calendar.ISO.date_from_iso_days(iso_days)
  end
end
