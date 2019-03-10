defmodule Cldr.Calendar.Options do
  defstruct [
    format: :wide,
    locale: nil,
    module: nil,
    min_days: 4,
    first_day: 1,
    backend: nil
  ]

end