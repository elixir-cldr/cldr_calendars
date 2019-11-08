defmodule Cldr.Calendar.PeriodSequenceTest do
  use ExUnit.Case

  defmodule C454 do
    use Cldr.Calendar.Base.Week,
      day_of_week: 7,
      first_or_last: :first,
      min_days_in_first_week: 7,
      month_of_year: 2,
      weeks_in_month: [4, 5, 4]
  end

  test "an ascending sequence of months in a week calendar follow each other" do
    {:ok, d} = Date.new(1980, 1, 1, C454)
    m = Cldr.Calendar.Interval.month(d)
    Enum.reduce 1..1000, m, fn _i, m ->
      m2 = Cldr.Calendar.next(m, :month)
      assert Cldr.Calendar.date_to_iso_days(m.last) + 1 == Cldr.Calendar.date_to_iso_days(m2.first)
      m2
    end
  end

  test "an ascending sequence of weeks in a week calendar follow each other" do
    {:ok, d} = Date.new(1980, 1, 1, C454)
    m = Cldr.Calendar.Interval.week(d)
    Enum.reduce 1..1000, m, fn _i, m ->
      m2 = Cldr.Calendar.next(m, :week)
      assert Cldr.Calendar.date_to_iso_days(m.last) + 1 == Cldr.Calendar.date_to_iso_days(m2.first)
      m2
    end
  end

  test "an decending sequence of months in a week calendar follow each other" do
    {:ok, d} = Date.new(2030, 1, 1, C454)
    m = Cldr.Calendar.Interval.month(d)
    Enum.reduce 1..1000, m, fn _i, m ->
      m2 = Cldr.Calendar.previous(m, :month)
      IO.puts("Month: #{inspect m}; Previous: #{inspect m2}"
      assert Cldr.Calendar.date_to_iso_days(m2.last) + 1 == Cldr.Calendar.date_to_iso_days(m.first)
      m2
    end
  end

  test "an decending sequence of weeks in a week calendar follow each other" do
    {:ok, d} = Date.new(2030, 1, 1, C454)
    m = Cldr.Calendar.Interval.week(d)
    Enum.reduce 1..1000, m, fn _i, m ->
      m2 = Cldr.Calendar.previous(m, :week)
      assert Cldr.Calendar.date_to_iso_days(m2.last) + 1 == Cldr.Calendar.date_to_iso_days(m.first)
      m2
    end
  end
end