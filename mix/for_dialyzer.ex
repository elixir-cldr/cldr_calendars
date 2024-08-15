defmodule Cldr.Calendar.ForDialyzer do
  def test do
    Cldr.Calendar.localize(%{year: 2024}, :year)
    MyApp.Cldr.Calendar.localize(%{month: 2}, :month)

    Cldr.Calendar.localize(Date.utc_today(), :days_of_week)
    MyApp.Cldr.Calendar.localize(Date.utc_today(), :days_of_week)

    Cldr.Calendar.localize(Date.utc_today(), :month)
    Cldr.Calendar.localize(%{month: 3}, :month, format: :wide, locale: :da)

    MyApp.Cldr.Calendar.localize(%{month: 3}, :month, format: :wide, locale: :da)
  end

end
