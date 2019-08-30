defmodule Cldr.Calendar.Duration.Test do
  use ExUnit.Case, async: true
  alias Cldr.Calendar.Duration
  import Cldr.Calendar.Sigils

  test "durations" do
    assert Duration.duration(~D[2019-01-01], ~D[2019-12-31]) ==
      %Duration{year: 0, month: 11, day: 30, hour: 0, microsecond: 0, minute: 0, second: 0}

    assert Duration.duration(~D[2019-01-31], ~D[2019-02-01]) ==
      %Duration{year: 0, month: 0, day: 1, hour: 0, microsecond: 0, minute: 0, second: 0}

    assert Duration.duration(~D[2019-12-31], ~D[2020-01-01]) ==
      %Duration{year: 0, month: 0, day: 1, hour: 0, microsecond: 0, minute: 0, second: 0}

    assert Duration.duration(~D[2019-01-31], ~D[2020-01-01]) ==
      %Duration{year: 0, month: 11, day: 1, hour: 0, microsecond: 0, minute: 0, second: 0}

    assert Duration.duration(~D[2019-05-27], ~D[2019-08-30]) ==
      %Duration{year: 0, month: 3, day: 3, hour: 0, microsecond: 0, minute: 0, second: 0}

    assert Duration.duration(~D[2000-05-01], ~D[2019-12-31]) ==
      %Duration{year: 19, month: 7, day: 30, hour: 0, microsecond: 0, minute: 0, second: 0}

    assert Duration.duration(~D[2000-12-01], ~D[2019-01-31]) ==
      %Duration{year: 18, month: 1, day: 30, hour: 0, microsecond: 0, minute: 0, second: 0}

    assert Duration.duration(~d[2000-12-01 Gregorian], ~d[2019-01-31 Gregorian]) ==
      %Duration{year: 18, month: 1, day: 30, hour: 0, microsecond: 0, minute: 0, second: 0}

    assert Duration.duration(~d[2000-12-01 CSCO], ~d[2019-01-07 CSCO]) ==
      %Duration{year: 18, month: 1, day: 6, hour: 0, microsecond: 0, minute: 0, second: 0}
  end

end