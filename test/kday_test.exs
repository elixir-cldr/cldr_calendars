defmodule Calendar.Kday.Test do
  use ExUnit.Case, async: true

  test "nth kday for k-day == day of date" do
    assert Cldr.Calendar.Kday.nth_kday(~D[2022-01-01], 1, 5) == ~D[2022-01-07]
    assert Cldr.Calendar.Kday.nth_kday(~D[2022-01-01], -1, 5) == ~D[2021-12-31]
  end
end