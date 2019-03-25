require Cldr.Calendar
require Cldr.Calendar.Backend.Compiler

defmodule MyApp.Cldr do
  use Cldr,
    providers: [Cldr.Calendar],
    locales: ["en", "fr", "en-GB", "en-AU", "en-CA", "ar", "he"]
end

defmodule NoDocs.Cldr do
  use Cldr, generate_docs: false, providers: [Cldr.Calendar]
end
