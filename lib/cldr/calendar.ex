defmodule Cldr.Calendar do

  @callback day_name(Calendar.year, Calendar.month, Keyword.t) :: String.t()
  @callback month_name(Calendar.year, Calendar.month, Keyword.t) :: String.t()
  @callback quarter_name(Calendar.year, Calendar.month, Keyword.t) :: String.t()
  @callback era_name(Calendar.year, Calendar.month, Keyword.t) :: String.t()
  @callback week_of_year(Calendar.year, Calendar.month, Keyword.t) :: {Calendar.year, Calendar.week}

  @type day_of_the_week :: 1..7
  @type day_names :: :monday | :tuesday | :wednesday | :thursday | :friday | :saturday | :sunday
  @type date_or_time :: Date.t() | NaiveDateTime.t() | IsoDay.t() | map()

  @days_in_a_week 7

  @doc """
  Returns the integer representation of a day of the week.

  Both an atom representing the name of a day or a number between
  1 and 7 is acceptable with 1 meaning :monday and 7 meaning :sunday.

  ## Exmaples

      iex(1)> Cldr.Calendar.day_cardinal :monday
      1

      iex(2)> Cldr.Calendar.day_cardinal :friday
      5

      iex(3)> Cldr.Calendar.day_cardinal 5
      5

  """
  @spec day_cardinal(day_of_the_week | day_names) :: day_of_the_week
  def day_cardinal(:monday), do: 1
  def day_cardinal(:tuesday), do: 2
  def day_cardinal(:wednesday), do: 3
  def day_cardinal(:thursday), do: 4
  def day_cardinal(:friday), do: 5
  def day_cardinal(:saturday), do: 6
  def day_cardinal(:sunday), do: 7
  def day_cardinal(day_number) when day_number in 1..@days_in_a_week, do: day_number

  def day_name(1), do: :monday
  def day_name(2), do: :tuesday
  def day_name(3), do: :wednesday
  def day_name(4), do: :thursday
  def day_name(5), do: :friday
  def day_name(6), do: :saturday
  def day_name(7), do: :sunday

  @doc """
  Returns the number of days in `n` weeks

  ## Example

      iex> Cldr.Calendar.weeks(2)
      14

  """
  @spec weeks(integer) :: integer
  def weeks(n) do
    n * @days_in_a_week
  end

  def week_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.week_of_year(year, month, day)
  end

  def day_name(date, backend, options \\ []) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    options = Keyword.merge(options, [backend: backend])
    calendar.day_name(year, month, day, options)
  end

  def month_name(date, backend, options \\ []) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    options = Keyword.merge(options, [backend: backend])
    calendar.month_name(year, month, day, options)
  end

  def quarter_name(date, backend, options \\ []) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    options = Keyword.merge(options, [backend: backend])
    calendar.quarter_name(year, month, day, options)
  end

  def era_name(date, backend, options \\ []) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    options = Keyword.merge(options, [backend: backend])
    calendar.era_name(year, month, day, options)
  end

  @doc false
  def cldr_backend_provider(config) do
    Cldr.Calendar.Backend.Compiler.define_calendar_modules(config)
  end

  @doc false
  def calendar_error(calendar_name) do
    {Cldr.UnknownCalendarError, "The calendar #{inspect(calendar_name)} is not known."}
  end

  def date_to_iso_days(%{year: year, month: month, day: day, calendar: calendar}) do
    calendar.date_to_iso_days(year, month, day)
  end

  def date_from_iso_days(days, calendar) do
    {year, month, day} = calendar.date_from_iso_days(days)
    {:ok, date} = Date.new(year, month, day, calendar)
    date
  end

  def iso_days_to_day_of_week(iso_days) do
    Integer.mod(iso_days + 5, 7) + 1
  end

end
