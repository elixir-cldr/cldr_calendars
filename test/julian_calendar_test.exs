defmodule Cldr.Calendar.Julian.Test do
  use ExUnit.Case, async: true

  test "that we can localize a julian date" do
    import Cldr.Calendar.Sigils

    assert Cldr.Calendar.localize(~d[2019-03-01]Julian, :era) == "AD"
  end
end
