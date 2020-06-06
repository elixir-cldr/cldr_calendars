defmodule Cldr.Calendar.RD do
  # Add to mix.exs
  #   {ex_cldr_calendars: "~> 2.0"}
  # Get deps
  #   mix deps.get
  # Fire up iex
  #
  # iex> d = ~D[0001-01-01 Cldr.Calendar.RD]
  # ~D[0001-01-01 Cldr.Calendar.RD]
  # iex> Date.convert! d, Calendar.ISO
  # ~D[0001-01-01]
  # iex> Date.convert!(d, Calendar.ISO) |> Date.convert!(Cldr.Calendar.RD)
  # ~D[0001-01-01 Cldr.Calendar.RD]

  @offset 365

  def date_from_iso_days(iso_days) do
    Cldr.Calendar.Gregorian.date_from_iso_days(iso_days - @offset)
  end

  def date_to_iso_days(year, month, day) do
    Cldr.Calendar.Gregorian.date_to_iso_days(year, month, day) + @offset
  end

  fun =
    quote do
      :"$handle_undefined_function"
    end

  def unquote(fun)(func, args) do
    apply(Calendar.Gregorian, func, args)
  end
end
