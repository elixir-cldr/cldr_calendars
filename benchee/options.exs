Benchee.run(%{
  "cldr" => fn -> Cldr.Calendar.Gregorian.extract_options(backend: MyApp.Cldr) end
})