defmodule Cldr.Calendar.Test do
  use ExUnit.Case
  doctest Cldr.Calendar
  doctest Cldr.Calendar.Kday

  # :calendar module doesn't work with year 0 or negative years
  test "that iso week of year is same as erlang" do
    for year <- 0001..2200,
        month <- 1..12,
        day <- 1..Cldr.Calendar.Gregorian.days_in_month(year, month) do
      assert :calendar.iso_week_number({year, month, day}) ==
               Cldr.Calendar.Gregorian.iso_week_of_year(year, month, day)
    end
  end

  test "that no module docs are generated for a backend" do
    assert {:docs_v1, _, :elixir, _, :hidden, %{}, _} = Code.fetch_docs(NoDocs.Cldr.Calendar)
  end

  assert "that module docs are generated for a backend" do
    {:docs_v1, _, :elixir, "text/markdown", _, %{}, _} = Code.fetch_docs(MyApp.Cldr.Calendar)
  end
end
