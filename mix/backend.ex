require Cldr.Calendar
require Cldr.Calendar.Backend.Compiler

defmodule MyApp.Cldr do
  use Cldr,
    providers: [Cldr.Calendar, Cldr.Number, Cldr.Unit, Cldr.List],
    locales: ["en", "fr", "en-GB", "en-AU", "en-CA", "ar", "he"],
    default_locale: "en"
end

defmodule NoDocs.Cldr do
  use Cldr,
    generate_docs: false,
    providers: [Cldr.Calendar]
end
