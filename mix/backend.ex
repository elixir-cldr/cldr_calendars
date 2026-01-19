{:module, _} = Code.ensure_compiled(Cldr.Calendar.Backend)
{:module, _} = Code.ensure_compiled(Cldr.Calendar.Backend.Compiler)
require Cldr.Calendar

defmodule MyApp.Cldr do
  use Cldr,
    providers: [Cldr.Calendar, Cldr.Number, Cldr.Unit, Cldr.List],
    locales: ["en", "fr", "en-GB", "en-AU", "en-CA", "ar", "he", "fa", "zh", "de", "da"],
    default_locale: "en"
end

defmodule NoDocs.Cldr do
  use Cldr,
    generate_docs: false,
    providers: [Cldr.Calendar]
end
