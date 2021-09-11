defmodule Cldr.Calendar.Era do
  @moduledoc """
  Encapsulates the era information for
  known CLDR calendars

  The [era data in CLDR](https://github.com/unicode-org/cldr/blob/master/common/supplemental/supplementalData.xml)
  is presented in different calendars at different times. The current
  best understanding is:

  ### Japanese Calendar

  * From Taisho (1912), the date is Gregorian year,
    month and day.

  * For Tenshō (Momoyama period) to Meji era (1868)
    inclusive its Gregorian year but lunar month and day.

  * For earlier eras it is Julian year with lunar month and
    day (but the Julian and Gregorian years coincide, there are
    no era dates where the Gregorian year would be different
    to the Julian year).

  ### Other Calendars

  * For Chinese and Korean (dangi) the era dates are
    Gregorian year with lunar month and lunar day

  * For Coptic, Ethiopic and Islamic calendars the eras are
    Julian dates (Julian day, month and year).

  * Perian era is Julian year with persian month and day.

  * Gregorian is, well, Gregorian date.

  """

  # Just after a calendar is defined this function
  # is called to create a module that provides a
  # lookup function returning the appropriate era
  # number for a given date in a given calendar.
  #
  # If the calendar does not have a known CLDR
  # calendar name associated with it then no
  # module is produced

  @doc false
  def define_era_module(calendar_module) do
    if function_exported?(calendar_module, :cldr_calendar_type, 0) &&
        !Code.ensure_loaded?(era_module(calendar_module.cldr_calendar_type())) do
      cldr_calendar = calendar_module.cldr_calendar_type()
      era_module = era_module(cldr_calendar)

      cldr_calendar
      |> eras_for_calendar()
      |> eras_to_iso_days(cldr_calendar, calendar_module)
      |> IO.inspect
      |> define_era_module(era_module)
    else
      :no_op
    end
  end

  # Returns a list of eras with the most
  # recent era first (we want this sort
  # order so that when we generate function
  # clauses, most recent dates match first and
  # those are the dates most likely to be used).

  defp eras_for_calendar(calendar) do
    Cldr.Config.calendars()
    |> Map.fetch!(calendar)
    |> Map.fetch!(:eras)
    |> Enum.reverse
  end

  defp eras_to_iso_days(eras, :japanese, calendar) do
    Enum.map eras, fn
      [era, %{start: [year, month, day]}] when year >= 1912 ->
        [era, Cldr.Calendar.Gregorian.date_to_iso_days(year, month, day)]
      [era, %{start: [year, month, day]}]  ->
        [era, calendar.date_to_iso_days(year, month, day)]
    end
  end

  @eras_in_gregorian_year [
    :chinese,
    :dangi,
    :persian,
    :gregorian
  ]

  defp eras_to_iso_days(eras, cldr_calendar, calendar)
      when cldr_calendar in @eras_in_gregorian_year do
    Enum.map eras, fn [era, %{start: [year, month, day]}]  ->
      [era, calendar.date_to_iso_days(year, month, day) - calendar.epoch()]
    end
  end

  @eras_in_julian_calendar [
    :coptic,
    :ethiopic,
    :islamic,
    :islamic_civil,
    :islamic_rgsa,
    :islamic_tbla,
    :islamic_umalqura
  ]

  defp eras_to_iso_days(eras, cldr_calendar, _calendar)
      when cldr_calendar in @eras_in_julian_calendar do
    Enum.map eras, fn [era, %{start: [year, month, day]}]  ->
      [era, Cldr.Calendar.Julian.date_to_iso_days(year, month, day)]
    end
  end

  defp eras_to_iso_days(eras, cldr_calendar, calendar) do
    IO.inspect {cldr_calendar, calendar, eras}
  end

  defp define_era_module(eras, module) do
    {eras, module}
  end

  defp era_module(calendar) do
    module = to_string(calendar) |> String.capitalize()
    Module.concat(Cldr.Calendar.Era, module)
  end
end