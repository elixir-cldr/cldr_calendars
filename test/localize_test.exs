defmodule Cldr.Calendar.LocalizeTest do
  use ExUnit.Case, async: true

  test "Localized era with variant" do
    assert Cldr.Calendar.localize(~D[2019-01-01], :era, era: :variant) == "CE"
    assert Cldr.Calendar.localize(~D[-2019-01-01], :era, era: :variant) == "BCE"
  end
end