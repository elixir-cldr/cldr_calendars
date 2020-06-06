defmodule Cldr.Calendar.Protocol.Test do
  use ExUnit.Case

  test "String.Chars" do
    assert to_string Cldr.Calendar.Duration.new!(~D[2020-01-01], ~D[2020-02-01]) ==
    "1 month"

    assert to_string Cldr.Calendar.Duration.new!(~D[2020-01-01], ~D[2020-03-01]) ==
    "2 months"

    assert to_string Cldr.Calendar.Duration.new!(~D[2020-01-01], ~D[2020-03-04]) ==
    "2 months and 3 days"

    assert to_string Cldr.Calendar.Duration.new!(~D[2020-01-01], ~D[2021-03-04]) ==
    "1 year, 2 months and 3 days"

    assert to_string Cldr.Calendar.Duration.new!(~D[2020-01-01], ~U[2021-03-04 01:02:03.0Z]) ==
    "1 year, 2 months, 3 days, 1 hour, 2 minutes and 3 seconds"
  end

  test "Cldr.Chars" do
    assert Cldr.to_string Cldr.Calendar.Duration.new!(~D[2020-01-01], ~D[2020-02-01]) ==
    "1 month"

    assert Cldr.to_string Cldr.Calendar.Duration.new!(~D[2020-01-01], ~D[2020-03-01]) ==
    "2 months"

    assert Cldr.to_string Cldr.Calendar.Duration.new!(~D[2020-01-01], ~D[2020-03-04]) ==
    "2 months and 3 days"

    assert Cldr.to_string Cldr.Calendar.Duration.new!(~D[2020-01-01], ~D[2021-03-04]) ==
    "1 year, 2 months and 3 days"

    assert Cldr.to_string Cldr.Calendar.Duration.new!(~D[2020-01-01], ~U[2021-03-04 01:02:03.0Z]) ==
    "1 year, 2 months, 3 days, 1 hour, 2 minutes and 3 seconds"
  end

end