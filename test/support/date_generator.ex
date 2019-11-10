defmodule Calendar.Date do
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
  def generate_date do
    ExUnitProperties.gen all year <- StreamData.integer(0001..2200),
                             week <- StreamData.integer(1..53),
                             day <-  StreamData.integer(1..7),
                             calendar <- StreamData.member_of(@week_calendars) do

      week = min(week, Cldr.Calendar.weeks_in_year(year, calendar))
      {:ok, date} = Date.new(year, week, day, calendar)
      date
    end
  end
end
