defmodule Cldr.Calendar.ForDialyzer do
  def test do
    Cldr.Calendar.localize(Date.utc_today(), :month)
  end
end
