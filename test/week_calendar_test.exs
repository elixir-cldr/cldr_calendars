defmodule Cldr.Calendar.Week.Test do
  use ExUnit.Case

  test "tuesday week calendar" do
    defmodule Tuesday do
      use Cldr.Calendar.Base.Week,
        day: 2, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.new(2019,13,4,Tuesday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Tuesday, day: 4, month: 13, year: 2018}
  end

  test "wednesday week calendar" do
    defmodule Wednesday do
      use Cldr.Calendar.Base.Week,
        day: 3, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.new(2019,13,4,Wednesday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Wednesday, day: 4, month: 13, year: 2018}
  end

  test "thursday week calendar" do
    defmodule Thursday do
      use Cldr.Calendar.Base.Week,
        day: 4, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.new(2019,13,4,Thursday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Thursday, day: 4, month: 13, year: 2018}
  end

  test "friday week calendar" do
    defmodule Friday do
      use Cldr.Calendar.Base.Week,
        day: 5, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.new(2019,13,4,Friday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Friday, day: 4, month: 13, year: 2018}
  end

  test "saturday week calendar" do
    defmodule Saturday do
      use Cldr.Calendar.Base.Week,
        day: 6, month: 1, weeks_in_month: [5, 4, 4], min_days: 7
    end

    {:ok, today} = Date.new(2019,13,4,Saturday)
    last_year_day = Cldr.Calendar.previous(today, :year)
    assert last_year_day == %Date{calendar: Saturday, day: 4, month: 13, year: 2018}
  end

end