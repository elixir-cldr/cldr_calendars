defmodule Cldr.Calendar.DateConvert.Test do
  use ExUnit.Case
  alias Cldr.Calendar.Base.Month
  alias Cldr.Calendar.Config

  test "that {2019, 1, 1} converts to {2018, 12, 1} for month-based calendar starting in Feb " do
    assert Month.date_from_iso_date(2019, 1, 1, %Config{month_of_year: 2}) == {2018, 12, 1}
  end

  test "that {2019, 2, 1} converts to {2019, 1, 1} for month-based calendar starting in Feb " do
    assert Month.date_from_iso_date(2019, 2, 1, %Config{month_of_year: 2}) == {2019, 1, 1}
  end

  test "that {2019, 3, 1} converts to {2019, 2, 1} for month-based calendar starting in Feb " do
    assert Month.date_from_iso_date(2019, 3, 1, %Config{month_of_year: 2}) == {2019, 2, 1}
  end

  test "that {2019, 4, 1} converts to {2019, 3, 1} for month-based calendar starting in Feb " do
    assert Month.date_from_iso_date(2019, 4, 1, %Config{month_of_year: 2}) == {2019, 3, 1}
  end

  test "that {2019, 12, 1} converts to {2019, 11, 1} for month-based calendar starting in Feb " do
    assert Month.date_from_iso_date(2019, 12, 1, %Config{month_of_year: 2}) == {2019, 11, 1}
  end

  test "that {2018, 12, 1} re-converts to {2019, 1, 1} for month-based calendar starting in Feb " do
    assert Month.date_to_iso_date(2018, 12, 1, %Config{month_of_year: 2}) == {2019, 1, 1}
  end

  test "that {2019, 1, 1} re-converts to {2019, 2, 1} for month-based calendar starting in Feb " do
    assert Month.date_to_iso_date(2019, 1, 1, %Config{month_of_year: 2}) == {2019, 2, 1}
  end

  test "that {2019, 2, 1} re-converts to {2019, 3, 1} for month-based calendar starting in Feb " do
    assert Month.date_to_iso_date(2019, 2, 1, %Config{month_of_year: 2}) == {2019, 3, 1}
  end

  test "that {2019, 3, 1} re-converts to {2019, 4, 1} for month-based calendar starting in Feb " do
    assert Month.date_to_iso_date(2019, 3, 1, %Config{month_of_year: 2}) == {2019, 4, 1}
  end

  test "that {2019, 11, 1} re-converts to {2019, 12, 1} for month-based calendar starting in Feb " do
    assert Month.date_to_iso_date(2019, 11, 1, %Config{month_of_year: 2}) == {2019, 12, 1}
  end
end
