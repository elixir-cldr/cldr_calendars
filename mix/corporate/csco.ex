require Cldr.Calendar.Compiler.Week

defmodule Cldr.Calendar.CSCO do
  use Cldr.Calendar.Base.Week,
    min_days_in_first_week: 7,
    begins_or_ends: :ends,
    first_or_last: :last,
    day_of_week: 6,
    month_of_year: 7
end
