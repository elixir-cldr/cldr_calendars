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

  defmodule C544 do
    use Cldr.Calendar.Base.Week,
      day_of_week: 1,
      first_or_last: :first,
      min_days_in_first_week: 7,
      month_of_year: 1,
      weeks_in_month: [5, 4, 4]
  end

  for calendar <- [C454, C544] do
    test "an ascending sequence of quarters in #{inspect(calendar)} follow each other" do
      {:ok, d} = Date.new(1900, 1, 1, unquote(calendar))
      m = Cldr.Calendar.Interval.quarter(d)

      Enum.reduce(1..5000, m, fn _i, m ->
        m2 = Cldr.Calendar.next(m, :quarter, coerce: true)

        assert Cldr.Calendar.date_to_iso_days(m.last) + 1 ==
                 Cldr.Calendar.date_to_iso_days(m2.first)

        m2
      end)
    end

    test "an ascending sequence of months in #{inspect(calendar)} follow each other" do
      {:ok, d} = Date.new(1900, 1, 1, unquote(calendar))
      m = Cldr.Calendar.Interval.month(d)

      Enum.reduce(1..5000, m, fn _i, m ->
        m2 = Cldr.Calendar.next(m, :month, coerce: true)

        assert Cldr.Calendar.date_to_iso_days(m.last) + 1 ==
                 Cldr.Calendar.date_to_iso_days(m2.first)

        m2
      end)
    end

    test "an ascending sequence of weeks in #{inspect(calendar)} follow each other" do
      {:ok, d} = Date.new(1900, 1, 1, unquote(calendar))
      m = Cldr.Calendar.Interval.week(d)

      Enum.reduce(1..5000, m, fn _i, m ->
        m2 = Cldr.Calendar.next(m, :week, coerce: true)

        assert Cldr.Calendar.date_to_iso_days(m.last) + 1 ==
                 Cldr.Calendar.date_to_iso_days(m2.first)

        m2
      end)
    end

    test "a descending sequence of quarters in #{inspect(calendar)} follow each other" do
      {:ok, d} = Date.new(2050, 1, 1, unquote(calendar))
      m = Cldr.Calendar.Interval.quarter(d)

      Enum.reduce(1..5000, m, fn _i, m ->
        m2 = Cldr.Calendar.previous(m, :quarter, coerce: true)

        assert Cldr.Calendar.date_to_iso_days(m2.last) + 1 ==
                 Cldr.Calendar.date_to_iso_days(m.first)

        m2
      end)
    end

    test "a descending sequence of months in #{inspect(calendar)} follow each other" do
      {:ok, d} = Date.new(2050, 1, 1, unquote(calendar))
      m = Cldr.Calendar.Interval.month(d)

      Enum.reduce(1..5000, m, fn _i, m ->
        m2 = Cldr.Calendar.previous(m, :month, coerce: true)

        assert Cldr.Calendar.date_to_iso_days(m2.last) + 1 ==
                 Cldr.Calendar.date_to_iso_days(m.first)

        m2
      end)
    end

    test "a descending sequence of weeks in #{inspect(calendar)} follow each other" do
      {:ok, d} = Date.new(2050, 1, 1, unquote(calendar))
      m = Cldr.Calendar.Interval.week(d)

      Enum.reduce(1..5000, m, fn _i, m ->
        m2 = Cldr.Calendar.previous(m, :week, coerce: true)

        assert Cldr.Calendar.date_to_iso_days(m2.last) + 1 ==
                 Cldr.Calendar.date_to_iso_days(m.first)

        m2
      end)
    end
  end
end
