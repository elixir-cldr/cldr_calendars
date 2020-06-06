defmodule Cldr.Calendar.LocaleCalendar.Test do
  use ExUnit.Case, async: true

  test "that we get the Persian calendar for territory IR" do
    assert Cldr.Calendar.Preference.calendar_for_territory(:IR) ==
             {:ok, Cldr.Calendar.Persian}
  end

  test "that we get the Persian calendar for locale fa-IR" do
    {:ok, locale} = Cldr.validate_locale("fa-IR", MyApp.Cldr)

    assert Cldr.Calendar.Preference.calendar_for_locale(locale) ==
             {:ok, Cldr.Calendar.Persian}
  end

  test "that we get the Gregorian calendar for locale en-US" do
    {:ok, locale} = Cldr.validate_locale("en-US", MyApp.Cldr)

    assert Cldr.Calendar.Preference.calendar_for_locale(locale) ==
             {:ok, Cldr.Calendar.US}
  end

  test "that we get the Gregorian calendar for locale en-001" do
    {:ok, locale} = Cldr.validate_locale("en-001", MyApp.Cldr)

    assert Cldr.Calendar.Preference.calendar_for_locale(locale) ==
             {:ok, Cldr.Calendar.Gregorian}
  end

  test "that we get the Gregorian calendar for locale en" do
    {:ok, locale} = Cldr.validate_locale("en", MyApp.Cldr)

    assert Cldr.Calendar.Preference.calendar_for_locale(locale) ==
             {:ok, Cldr.Calendar.US}
  end
end
