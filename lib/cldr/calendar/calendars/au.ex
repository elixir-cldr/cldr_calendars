require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.AU do
  use Cldr.Calendar.Base.Month, first_month: 7, backend: MyApp.Cldr

end