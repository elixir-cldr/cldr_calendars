defmodule Cldr.Calendar.ForDialyzer do
  def test do
    Cldr.Calendar.localize(Date.utc_today(), :month)
    Cldr.Calendar.localize(%{month: 3}, :month, format: :wide, locale: :da)
    MyApp.Cldr.Calendar.localize(%{month: 3}, :month, format: :wide, locale: :da)
  end
end
