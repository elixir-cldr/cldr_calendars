defmodule Compare do
  def print do
    format = "%10s %10s %10s %10s %10s\n"
    iso = %{min_days: 4, first_day: 1}
    en = Cldr.Calendar.Gregorian.extract_options locale: "en", backend: MyApp.Cldr
    en_001 = Cldr.Calendar.Gregorian.extract_options locale: "en-001", backend: MyApp.Cldr

    erl = "erl [#{inspect iso.first_day},#{inspect iso.min_days}]"
    iso = "iso [#{inspect iso.first_day},#{inspect iso.min_days}]"
    en = "en [#{inspect en.first_day},#{inspect en.min_days}] "
    en_001 = "en_001 [#{inspect en_001.first_day},#{inspect en_001.min_days}]"

    Cldr.Print.printf(format, ["date   ", erl, iso, en, en_001])
    for year <- 2019..2019, month <- 1..12, day <- 1..Calendar.ISO.days_in_month(year, month) do
      {:ok, date} = Date.new(year, month, day, Cldr.Calendar.Gregorian)
      erl = :calendar.iso_week_number {year, month, day}
      iso = Cldr.Calendar.iso_week_of_year date, MyApp.Cldr
      en = Cldr.Calendar.week_of_year date, MyApp.Cldr, locale: "en"
      en_001 = Cldr.Calendar.week_of_year date, MyApp.Cldr, locale: "en-001"
      Cldr.Print.printf(format, [to_string(date), inspect(erl), inspect(iso), inspect(en), inspect(en_001)])
    end
    :ok
  end
end