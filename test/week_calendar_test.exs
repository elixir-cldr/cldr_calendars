defmodule Cldr.Calendar.Week.Test do
  use ExUnit.Case

  defmodule Sunday do
    use Cldr.Calendar.Base.Week, day: 7, month: 4, weeks_in_month: [4, 4, 5], min_days: 7
  end

  test "tuesday week calendar" do
    defmodule Tuesday do
      use Cldr.Calendar.Base.Week, day: 2, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.new(2019, 13, 4, Tuesday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Tuesday, day: 4, month: 13, year: 2018}
  end

  test "wednesday week calendar" do
    defmodule Wednesday do
      use Cldr.Calendar.Base.Week, day: 3, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.new(2019, 13, 4, Wednesday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Wednesday, day: 4, month: 13, year: 2018}
  end

  test "thursday week calendar" do
    defmodule Thursday do
      use Cldr.Calendar.Base.Week, day: 4, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.new(2019, 13, 4, Thursday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Thursday, day: 4, month: 13, year: 2018}
  end

  test "friday week calendar" do
    defmodule Friday do
      use Cldr.Calendar.Base.Week, day: 5, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.new(2019, 13, 4, Friday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Friday, day: 4, month: 13, year: 2018}
  end

  test "saturday week calendar" do
    defmodule Saturday do
      use Cldr.Calendar.Base.Week, day: 6, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.new(2019, 13, 4, Saturday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Saturday, day: 4, month: 13, year: 2018}
  end

  test "sunday week calendar" do
    {:ok, today} = Date.new(2018, 53, 3, Sunday)
    current_period = Cldr.Calendar.month(today)
    first_day_of_period = current_period.first
    last_day_of_period = current_period.last
    assert first_day_of_period == %Date{calendar: Sunday, day: 1, month: 48, year: 2018}
    assert last_day_of_period == %Date{calendar: Sunday, day: 7, month: 53, year: 2018}
  end

  test "that previous month and next month actually are for a week calendar" do
    {:ok, today} = Date.new(2019, 4, 4)
    {:ok, today} = Date.convert(today, Sunday)
    this_period = Cldr.Calendar.month(today)

    previous = Cldr.Calendar.previous(this_period, :month)
    assert previous.first == %Date{calendar: Sunday, day: 1, month: 44, year: 2018}
    assert previous.last == %Date{calendar: Sunday, day: 7, month: 47, year: 2018}

    next = Cldr.Calendar.next(this_period, :month)
    assert next.first == %Date{calendar: Sunday, day: 1, month: 1, year: 2019}
    assert next.last == %Date{calendar: Sunday, day: 7, month: 4, year: 2019}
  end

  test "previous month for a week calendar transitioning to prior quarter" do
    defmodule Monday do
      use Cldr.Calendar.Base.Week, day: 1, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.convert(~D[2019-04-11], Monday)
    prior_period_day = Cldr.Calendar.previous(today, :month, coerce: true)
    prior_period = Cldr.Calendar.month(prior_period_day)

    last_day_of_prior_period = prior_period.last
    {:ok, gregorian_prior_last} = Date.convert(last_day_of_prior_period, Cldr.Calendar.Gregorian)


    assert gregorian_prior_last == %Date{
             calendar: Cldr.Calendar.Gregorian,
             day: 7,
             month: 4,
             year: 2019
           }
  end
end
