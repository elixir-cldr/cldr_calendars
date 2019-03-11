require Cldr.Calendar
require Cldr.Calendar.Backend.Compiler

defmodule MyApp.Cldr do
  use Cldr,
    providers: [],
    locales: ["en", "fr", "en-GB", "en-AU", "en-CA"]

end