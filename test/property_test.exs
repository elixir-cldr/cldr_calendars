defmodule Cldr.Calendar.PropertyTest do
  use ExUnit.Case
  use ExUnitProperties
  alias Calendar

  @max_runs 50_000

  property "next and previous weeks" do
    check all(date <- Calendar.Date.generate_date(), max_runs: @max_runs) do
      this = Cldr.Calendar.Interval.week(date)
      previous = Cldr.Calendar.previous(this, :week, coerce: true)
      next = Cldr.Calendar.next(this, :week, coerce: true)

      assert Cldr.Calendar.date_to_iso_days(this.last) + 1 ==
               Cldr.Calendar.date_to_iso_days(next.first)

      assert Cldr.Calendar.date_to_iso_days(previous.last) + 1 ==
               Cldr.Calendar.date_to_iso_days(this.first)
    end
  end

  property "next and previous months" do
    check all(date <- Calendar.Date.generate_date(), max_runs: @max_runs) do
      this = Cldr.Calendar.Interval.month(date)
      previous = Cldr.Calendar.previous(this, :month, coerce: true)
      next = Cldr.Calendar.next(this, :month, coerce: true)

      assert Cldr.Calendar.date_to_iso_days(this.last) + 1 ==
               Cldr.Calendar.date_to_iso_days(next.first)

      assert Cldr.Calendar.date_to_iso_days(previous.last) + 1 ==
               Cldr.Calendar.date_to_iso_days(this.first)
    end
  end

  property "next and previous quarters" do
    check all(date <- Calendar.Date.generate_date(), max_runs: @max_runs) do
      this = Cldr.Calendar.Interval.quarter(date)
      previous = Cldr.Calendar.previous(this, :quarter, coerce: true)
      next = Cldr.Calendar.next(this, :quarter, coerce: true)

      assert Cldr.Calendar.date_to_iso_days(this.last) + 1 ==
               Cldr.Calendar.date_to_iso_days(next.first)

      assert Cldr.Calendar.date_to_iso_days(previous.last) + 1 ==
               Cldr.Calendar.date_to_iso_days(this.first)
    end
  end
end
