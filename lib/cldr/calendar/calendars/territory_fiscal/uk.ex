require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.UK do
  use Cldr.Calendar.Base.Month,
    anchor: :first,
    month: 4,
    year: :ending

end
