require Cldr.Calendar.Compiler.Week

defmodule Cldr.Calendar.Symmetery do
  @moduledoc false

  use Cldr.Calendar.Base.Week,
    min_days_in_first_week: 4,
    first_or_last: :first,
    day_of_year: 1,
    month_of_year: 1,
    weeks_in_month: [4, 5, 4]
end
