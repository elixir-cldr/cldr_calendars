defmodule Cldr.Calendar.Week.Test do
  use ExUnit.Case, async: true
  import Cldr.Calendar.Helper
  alias Cldr.Test.Calendars

  test "that days of the last month of a long year is 35 or 42" do
    assert Cldr.Calendar.NRF.days_in_month(2012, 12) == 35
    assert Cldr.Calendar.ISOWeek.days_in_month(2015, 12) == 35

    assert Cldr.Calendar.NRF.days_in_month(2013, 12) == 28
    assert Cldr.Calendar.ISOWeek.days_in_month(2016, 12) == 28

    assert Calendars.Sunday.days_in_month(2012, 12) == 42
    assert Calendars.Sunday.days_in_month(2013, 12) == 35
  end

  # Day of week is always the ordinal day. And therefore for
  # week based calendars is just `day`.

  test "day of week for ISOWeek calendar is correct" do
    assert Cldr.Calendar.day_of_week(date(2019, 01, 01, Cldr.Calendar.ISOWeek)) == 1
  end

  test "day of week for NRF calendar is correct" do
    assert Cldr.Calendar.day_of_week(date(2019, 01, 01, Cldr.Calendar.NRF)) == 1
  end

  test "day of week for Sunday calendar is correct" do
    {:ok, date} = Date.new(2019, 1, 1, Calendars.Sunday)
    assert Cldr.Calendar.day_of_week(date) == 1
  end

  test "day of week for Saturday calendar is correct" do
    {:ok, date} = Date.new(2019, 1, 1, Calendars.Saturday)
    assert Cldr.Calendar.day_of_week(date) == 1
  end

  test "day of week for Friday calendar is correct" do
    {:ok, date} = Date.new(2019, 1, 1, Calendars.Friday)
    assert Cldr.Calendar.day_of_week(date) == 1
  end

  test "day of week for Thursday calendar is correct" do
    {:ok, date} = Date.new(2019, 1, 1, Calendars.Thursday)
    assert Cldr.Calendar.day_of_week(date) == 1
  end

  test "day of week for Wednesday calendar is correct" do
    {:ok, date} = Date.new(2019, 1, 1, Calendars.Wednesday)
    assert Cldr.Calendar.day_of_week(date) == 1
  end

  test "day of week for Tuesday calendar is correct" do
    {:ok, date} = Date.new(2019, 1, 1, Calendars.Tuesday)
    assert Cldr.Calendar.day_of_week(date) == 1
  end

  test "day of week for Monday calendar is correct" do
    {:ok, date} = Date.new(2019, 1, 1, Calendars.Monday)
    assert Cldr.Calendar.day_of_week(date) == 1
  end

  test "tuesday week calendar" do
    {:ok, today} = Date.new(2019, 13, 4, Calendars.Tuesday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Calendars.Tuesday, day: 4, month: 13, year: 2018}
  end

  test "wednesday week calendar" do
    {:ok, today} = Date.new(2019, 13, 4, Calendars.Wednesday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Calendars.Wednesday, day: 4, month: 13, year: 2018}
  end

  test "thursday week calendar" do
    {:ok, today} = Date.new(2019, 13, 4, Calendars.Thursday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Calendars.Thursday, day: 4, month: 13, year: 2018}
  end

  test "friday week calendar" do
    {:ok, today} = Date.new(2019, 13, 4, Calendars.Friday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Calendars.Friday, day: 4, month: 13, year: 2018}
  end

  test "saturday week calendar" do
    {:ok, today} = Date.new(2019, 13, 4, Calendars.Saturday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Calendars.Saturday, day: 4, month: 13, year: 2018}
  end

  test "sunday week calendar" do
    {:ok, today} = Date.new(2018, 53, 3, Calendars.Sunday)
    current_period = Cldr.Calendar.Interval.month(today)
    first_day_of_period = current_period.first
    last_day_of_period = current_period.last
    assert first_day_of_period == %Date{calendar: Calendars.Sunday, day: 1, month: 48, year: 2018}
    assert last_day_of_period == %Date{calendar: Calendars.Sunday, day: 7, month: 53, year: 2018}
  end

  test "that previous month and next month actually are for a week calendar" do
    {:ok, today} = Date.new(2019, 4, 4)
    {:ok, today} = Date.convert(today, Calendars.Sunday)
    this_period = Cldr.Calendar.Interval.month(today)

    previous = Cldr.Calendar.previous(this_period, :month, coerce: true)
    assert previous.first == %Date{calendar: Calendars.Sunday, day: 1, month: 44, year: 2018}
    assert previous.last == %Date{calendar: Calendars.Sunday, day: 7, month: 47, year: 2018}

    next = Cldr.Calendar.next(this_period, :month, coerce: true)
    assert next.first == %Date{calendar: Calendars.Sunday, day: 1, month: 1, year: 2019}
    assert next.last == %Date{calendar: Calendars.Sunday, day: 7, month: 4, year: 2019}
  end

  test "previous month for a week calendar transitioning to prior quarter" do
    {:ok, today} = Date.convert(~D[2019-04-11], Calendars.Monday)
    prior_period_day = Cldr.Calendar.previous(today, :month, coerce: true)
    prior_period = Cldr.Calendar.Interval.month(prior_period_day)

    last_day_of_prior_period = prior_period.last
    {:ok, gregorian_prior_last} = Date.convert(last_day_of_prior_period, Cldr.Calendar.Gregorian)

    assert gregorian_prior_last == %Date{
             calendar: Cldr.Calendar.Gregorian,
             day: 7,
             month: 4,
             year: 2019
           }
  end

  test "days in month without year" do
    config = %Cldr.Calendar.Config{weeks_in_month: [4, 4, 5]}

    assert Cldr.Calendar.Base.Week.days_in_month(1, config) == 28
    assert Cldr.Calendar.Base.Week.days_in_month(2, config) == 28
    assert Cldr.Calendar.Base.Week.days_in_month(3, config) == 35
    assert Cldr.Calendar.Base.Week.days_in_month(4, config) == 28

    assert Cldr.Calendar.Base.Week.days_in_month(12, config) == {:ambiguous, [35, 42]}
  end
end
