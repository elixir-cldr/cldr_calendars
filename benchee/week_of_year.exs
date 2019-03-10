options = Cldr.Calendar.Gregorian.extract_options backend: MyApp.Cldr
Benchee.run(%{
  "erlang"    => fn -> :calendar.iso_week_number({2019, 12, 30}) end,
  "cldr" => fn -> Cldr.Calendar.Gregorian.iso_week_of_year(2019, 12, 30, backend: MyApp.Cldr) end,
  "cldr_map_options" => fn -> Cldr.Calendar.Gregorian.iso_week_of_year(2019, 12, 30, options) end
})