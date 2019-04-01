require Cldr.Calendar.Compiler.Week

defmodule Cldr.Calendar.Symmetery do
  @moduledoc false

  use Cldr.Calendar.Base.Week,
    min_days: 4,
    first_or_last: :first,
    day: 1,
    month: 1,
    weeks_in_month: [4, 5, 4]
end
