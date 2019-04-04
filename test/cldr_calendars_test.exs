defmodule Cldr.Calendar.Test do
  use ExUnit.Case

  doctest Cldr.Calendar
  doctest Cldr.Calendar.Kday

  test "that previous year when a leap year for a week-based calendar is in error" do
    {:ok, date} = Date.new(2015, 53, 7, Cldr.Calendar.ISOWeek)
    assert Cldr.Calendar.previous(date, :year) == {:error, :invalid_date}
  end

  test "that previous year when a leap year for a month-based calendar is in error" do
    {:ok, date} = Date.new(2016, 2, 29, Cldr.Calendar.Gregorian)
    assert Cldr.Calendar.previous(date, :year) == {:error, :invalid_date}
  end

  test "that previous year when a leap year for a week-based calendar" do
    {:ok, date} = Date.new(2015, 53, 7, Cldr.Calendar.ISOWeek)

    assert Cldr.Calendar.previous(date, :year, coerce: true) ==
             %Date{calendar: Cldr.Calendar.ISOWeek, day: 7, month: 52, year: 2014}
  end

  test "that previous year when a leap year for a month-based calendar" do
    {:ok, date} = Date.new(2016, 2, 29, Cldr.Calendar.Gregorian)

    assert Cldr.Calendar.previous(date, :year, coerce: true) ==
             %Date{calendar: Cldr.Calendar.Gregorian, day: 28, month: 2, year: 2015}
  end

  test "that previous month and next month actually are for a week calendar" do
    defmodule Sunday do
      use Cldr.Calendar.Base.Week, day: 7, month: 4, weeks_in_month: [4, 4, 5], min_days: 7
    end

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

  if function_exported?(Code, :fetch_docs, 1) do
    test "that no module docs are generated for a backend" do
      assert {:docs_v1, _, :elixir, _, :hidden, %{}, _} = Code.fetch_docs(NoDocs.Cldr.Calendar)
    end

    assert "that module docs are generated for a backend" do
      {:docs_v1, _, :elixir, "text/markdown", _, %{}, _} = Code.fetch_docs(MyApp.Cldr.Calendar)
    end
  end
end
