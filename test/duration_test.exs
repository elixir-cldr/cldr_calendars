defmodule Cldr.Calendar.Duration.Test do
  use ExUnit.Case, async: true
  alias Cldr.Calendar.Duration

  test "durations" do
    assert Duration.duration(~D[2019-01-01], ~D[2019-12-31]) ==
      %Duration{year: 0, month: 11, day: 31}

    assert Duration.duration(~D[2019-01-31], ~D[2019-02-01]) ==
      %Duration{year: 0, month: 0, day: 1}

    assert Duration.duration(~D[2019-12-31], ~D[2020-01-01]) ==
      %Duration{year: 0, month: 0, day: 1}

    assert Duration.duration(~D[2019-01-31], ~D[2020-01-01]) ==
      %Duration{year: 0, month: 11, day: 1}
  end

end