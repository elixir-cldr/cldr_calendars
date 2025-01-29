defmodule Cldr.Calendar.StrftimeOptions.Test do
  use ExUnit.Case, async: true

  test "am_or_pm" do
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "en")[:am_pm_names].(:am) == "AM"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "en")[:am_pm_names].(:pm) == "PM"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "he")[:am_pm_names].(:am) == "לפנה״צ"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "he")[:am_pm_names].(:pm) == "אחה״צ"
  end

  test "day names" do
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "en")[:day_of_week_names].(1) == "Monday"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "en")[:day_of_week_names].(7) == "Sunday"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "he")[:day_of_week_names].(1) == "יום שני"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "he")[:day_of_week_names].(7) == "יום ראשון"
  end

  test "abbreviated day names" do
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "en")[:abbreviated_day_of_week_names].(1) ==
             "Mon"

    assert MyApp.Cldr.Calendar.strftime_options!(locale: "en")[:abbreviated_day_of_week_names].(7) ==
             "Sun"

    assert MyApp.Cldr.Calendar.strftime_options!(locale: "he")[:abbreviated_day_of_week_names].(1) ==
             "יום ב׳"

    assert MyApp.Cldr.Calendar.strftime_options!(locale: "he")[:abbreviated_day_of_week_names].(7) ==
             "יום א׳"
  end

  test "month names" do
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "en")[:month_names].(1) == "January"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "en")[:month_names].(12) == "December"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "he")[:month_names].(1) == "ינואר"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "he")[:month_names].(12) == "דצמבר"
  end

  test "abbreviated month names" do
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "en")[:abbreviated_month_names].(1) == "Jan"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "en")[:abbreviated_month_names].(12) == "Dec"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "he")[:abbreviated_month_names].(1) == "ינו׳"
    assert MyApp.Cldr.Calendar.strftime_options!(locale: "he")[:abbreviated_month_names].(12) == "דצמ׳"
  end

  test "invalid locale in options" do
    assert_raise Cldr.InvalidLanguageError, fn ->
      MyApp.Cldr.Calendar.strftime_options!(locale: "zz")[:abbreviated_month_names].(1)
    end
  end

  test "strftime with options" do
    assert Calendar.strftime(
             ~D[2019-11-03],
             "%a, %B %d %Y",
             MyApp.Cldr.Calendar.strftime_options!()
           ) ==
             "Sun, November 03 2019"

    assert Calendar.strftime(
             ~D[2019-11-03],
             "%A, %b %d %Y",
             MyApp.Cldr.Calendar.strftime_options!()
           ) ==
             "Sunday, Nov 03 2019"

    assert Calendar.strftime(
             ~D[2019-11-03],
             "%A, %b %d %Y",
             MyApp.Cldr.Calendar.strftime_options!(locale: "fr")
           ) ==
             "dimanche, nov. 03 2019"

    assert Calendar.strftime(
             ~D[2019-11-03],
             "%A, %B %d %Y",
             MyApp.Cldr.Calendar.strftime_options!(locale: "he")
           ) ==
             "יום ראשון, נובמבר 03 2019"

    {:ok, dt} = NaiveDateTime.new(2019, 8, 26, 13, 52, 06, 0)

    assert Calendar.strftime(
             dt,
             "%y-%m-%d %I:%M:%S %p",
             MyApp.Cldr.Calendar.strftime_options!(locale: "fr")
           ) ==
             "19-08-26 01:52:06 PM"

    assert Calendar.strftime(
             dt,
             "%y-%m-%d %I:%M:%S %p",
             MyApp.Cldr.Calendar.strftime_options!(locale: "he")
           ) ==
             "19-08-26 01:52:06 אחה״צ"

    assert_raise Cldr.InvalidLanguageError, fn ->
      Calendar.strftime(
        dt,
        "%y-%m-%d %I:%M:%S %p",
        MyApp.Cldr.Calendar.strftime_options!(locale: "zz")
      )
    end
  end
end
