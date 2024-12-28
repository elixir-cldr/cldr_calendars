require Cldr.Calendar.Compiler.Month

defmodule Cldr.Calendar.SequentialWeeks do
  @moduledoc false

  # Weeks start on day 1 of the year and therefore
  # we have a partial last week of year.

  use Cldr.Calendar.Base.Month,
    month_of_year: 1,
    day_of_week: :first
end
