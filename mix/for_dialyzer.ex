defmodule Cldr.Calendar.ForDialyzer do
  def localize do
    Cldr.Calendar.localize(%{year: 2024}, :year)
    MyApp.Cldr.Calendar.localize(%{month: 2}, :month)

    Cldr.Calendar.localize(Date.utc_today(), :days_of_week)
    MyApp.Cldr.Calendar.localize(Date.utc_today(), :days_of_week)

    Cldr.Calendar.localize(Date.utc_today(), :month)
    Cldr.Calendar.localize(%{month: 3}, :month, format: :wide, locale: :da)

    MyApp.Cldr.Calendar.localize(%{month: 3}, :month, format: :wide, locale: :da)

    {:ok, duration} = Cldr.Calendar.Duration.new(~D[2019-01-01], ~D[2019-12-31])
    Cldr.Calendar.Duration.to_string!(duration)
  end
end
