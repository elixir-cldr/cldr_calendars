defmodule Cldr.Calendar.Range.Relationship.Test do
  use ExUnit.Case, async: true

  test "that a range precedes" do
    r1 = Cldr.Calendar.Interval.month(2019, 1)
    r2 = Cldr.Calendar.Interval.month(2019, 3)
    assert Cldr.Calendar.Interval.compare(r1, r2) == :precedes
  end

  test "that a range meets" do
    r1 = Cldr.Calendar.Interval.month(2019, 1)
    r2 = Cldr.Calendar.Interval.month(2019, 2)
    assert Cldr.Calendar.Interval.compare(r1, r2) == :meets
  end

  test "that a range overlaps" do
    r1 = Date.range(~D[2019-01-01], ~D[2019-01-31])
    r2 = Date.range(~D[2019-01-15], ~D[2019-02-28])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :overlaps
  end

  test "that a range is finished_by" do
    r1 = Date.range(~D[2019-01-01], ~D[2019-01-31])
    r2 = Date.range(~D[2019-01-15], ~D[2019-01-31])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :finished_by
  end

  test "that a range contains" do
    r1 = Date.range(~D[2019-01-01], ~D[2019-01-31])
    r2 = Date.range(~D[2019-01-15], ~D[2019-01-20])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :contains
  end

  test "that a range starts" do
    r1 = Date.range(~D[2019-01-01], ~D[2019-01-15])
    r2 = Date.range(~D[2019-01-01], ~D[2019-01-31])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :starts
  end

  test "that a range started_by" do
    r1 = Date.range(~D[2019-01-01], ~D[2019-01-31])
    r2 = Date.range(~D[2019-01-01], ~D[2019-01-15])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :started_by
  end

  test "that a range is during" do
    r1 = Date.range(~D[2019-01-10], ~D[2019-01-15])
    r2 = Date.range(~D[2019-01-01], ~D[2019-01-31])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :during
  end

  test "that a range finishes" do
    r1 = Date.range(~D[2019-01-15], ~D[2019-01-31])
    r2 = Date.range(~D[2019-01-01], ~D[2019-01-31])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :finishes
  end

  test "that a range is overlapped_by" do
    r1 = Date.range(~D[2019-01-10], ~D[2019-01-31])
    r2 = Date.range(~D[2019-01-01], ~D[2019-01-15])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :overlapped_by
  end

  test "that a range is met_by" do
    r1 = Date.range(~D[2019-01-15], ~D[2019-01-31])
    r2 = Date.range(~D[2019-01-01], ~D[2019-01-14])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :met_by
  end

  test "that a range is preceded_by" do
    r1 = Date.range(~D[2019-01-10], ~D[2019-01-15])
    r2 = Date.range(~D[2019-01-01], ~D[2019-01-05])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :preceded_by
  end

  test "that a range is overlapped by too" do
    r1 = Date.range(~D[2024-09-11], ~D[2300-01-01])
    r2 = Date.range(~D[2024-09-09], ~D[2024-09-11])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :overlapped_by
  end

  test "that a range overlaps too" do
    r1 = Date.range(~D[2024-09-09], ~D[2024-09-11])
    r2 = Date.range(~D[2024-09-11], ~D[2300-01-01])
    assert Cldr.Calendar.Interval.compare(r1, r2) == :overlaps
  end

end
