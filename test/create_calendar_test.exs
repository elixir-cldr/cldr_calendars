defmodule Cldr.Calendar.Create.Test do
  use ExUnit.Case

  test "that we can create a calendar with a month configuration" do
    assert {:ok, module} = Cldr.Calendar.new(:my_new_calendar, :week, weeks_in_month: [4, 4, 5])
  end
end
