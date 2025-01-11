defmodule Cldr.Calendar.Date do
  require ExUnitProperties

  @week_calendars [
    Cldr.Calendar.NRF,
    Cldr.Calendar.ISOWeek,
    Cldr.Calendar.CSCO,
    Cldr.Test.Calendars.Monday,
    Cldr.Test.Calendars.Tuesday,
    Cldr.Test.Calendars.Wednesday,
    Cldr.Test.Calendars.Thursday,
    Cldr.Test.Calendars.Friday,
    Cldr.Test.Calendars.Saturday,
    Cldr.Test.Calendars.Sunday
  ]

  @dialyzer {:nowarn_function, {:generate_date_in_week_calendar, 0}}
  def generate_date_in_week_calendar do
    ExUnitProperties.gen all(
                           year <- StreamData.integer(1900..2100),
                           week <- StreamData.integer(1..53),
                           day <- StreamData.integer(1..7),
                           calendar <- StreamData.member_of(@week_calendars)
                         ) do
      {weeks_in_year, _days_in_last_week} = Cldr.Calendar.weeks_in_year(year, calendar)
      week = min(week, weeks_in_year)
      {:ok, date} = Date.new(year, week, day, calendar)
      date
    end
  end

  def generate_date_in_calendar(calendar \\ Calendar.ISO) do
    ExUnitProperties.gen all(
                           year <- StreamData.integer(1970..2050),
                           month <- StreamData.integer(1..12),
                           day <- StreamData.integer(1..31),
                           match?({:ok, _}, Date.new(year, month, day, calendar))
                         ) do
      {:ok, date} = Date.new(year, month, day, calendar)
      date
    end
  end
end
