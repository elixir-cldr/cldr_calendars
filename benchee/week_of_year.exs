Benchee.run(%{
  "erlang"    => fn -> :calendar.iso_week_number({2019, 12, 30}) end,
  "cldr_calendar" => fn -> Cldr.Calendar.Gregorian.iso_week_of_year(2019, 12, 30) end,
  "cldr_direct" => fn -> Cldr.Calendar.Gregorian.week_of_year(2019, 12, 30, 1, 4) end
})