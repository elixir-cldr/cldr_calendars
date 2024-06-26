defmodule Cldr.Calendar.LocalizeTest do
  use ExUnit.Case, async: true

  test "Localized era with variant" do
    assert Cldr.Calendar.localize(~D[2019-01-01], :era, era: :variant) == "CE"
    assert Cldr.Calendar.localize(~D[-2019-01-01], :era, era: :variant) == "BCE"
  end

  test "Localized am/pm with variant" do
    assert Cldr.Calendar.localize(%{hour: 11}, :am_pm, period: :variant) == "am"
    assert Cldr.Calendar.localize(%{hour: 12}, :am_pm, period: :variant) == "pm"
  end
end
