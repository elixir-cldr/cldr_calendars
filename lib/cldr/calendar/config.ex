defmodule Cldr.Calendar.Config do
  defstruct format: :wide,
            locale: nil,
            min_days: 4,
            first_day: 1,
            backend: nil,
            calendar: nil
end
