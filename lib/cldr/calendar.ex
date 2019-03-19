defmodule Cldr.Calendar do
  @type week :: pos_integer()
  @type day_of_the_week :: 1..7
  @type day_names :: :monday | :tuesday | :wednesday | :thursday | :friday | :saturday | :sunday
  @type date_or_time :: Date.t() | NaiveDateTime.t() | IsoDay.t() | map()

  @callback week_of_year(Calendar.year(), Calendar.month(), Calendar.day()) ::
              {Calendar.year(), Calendar.week()}

  @callback iso_week_of_year(Calendar.year(), Calendar.month(), Calendar.day()) ::
              {Calendar.year(), Calendar.week()}

  @callback first_day_of_year(Calendar.year()) :: Date.t()
  @callback last_day_of_year(Calendar.year()) :: Date.t()

  # @callback year(Calendar.year()) :: Date.Range.t()
  # @callback quarter(Calendar.year(), Calendar.quarter()) :: Date.Range.t()
  # @callback month(Calendar.year(), Calendar.month()) :: Date.Range.t()
  # @callback week(Calendar.year(), Calendar.week()) :: Date.Range.t()

  @days [1, 2, 3, 4, 5, 6, 7]
  @days_in_a_week Enum.count(@days)
  @the_world :"001"

  alias Cldr.LanguageTag
  alias Cldr.Calendar.Config

  @doc false
  def cldr_backend_provider(config) do
    Cldr.Calendar.Backend.Compiler.define_calendar_modules(config)
  end

  def first_day_of_year(year, calendar) do
    year
    |> calendar.first_day_of_year
    |> date_from_iso_days(calendar)
  end

  def first_day_of_year(%{year: year, calendar: calendar}) do
    first_day_of_year(year, calendar)
  end

  def last_day_of_year(year, calendar) do
    year
    |> calendar.last_day_of_year
    |> date_from_iso_days(calendar)
  end

  def last_day_of_year(%{year: year, calendar: calendar}) do
    calendar.last_day_of_year(year)
  end

  def iso_week_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.iso_week_of_year(year, month, day)
  end

  def week_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.week_of_year(year, month, day)
  end

  def weekend?(date, options \\ []) do
    locale = Keyword.get(options, :locale, Cldr.get_locale())
    territory = Keyword.get(options, :territory, locale.territory)
    day_of_week(date) in weekend(territory)
  end

  def weekday?(date, options \\ []) do
    locale = Keyword.get(options, :locale, Cldr.get_locale())
    territory = Keyword.get(options, :territory, locale.territory)
    day_of_week(date) in weekdays(territory)
  end

  def date_to_iso_days(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.date_to_iso_days(year, month, day)
  end

  def date_from_iso_days({days, _}, calendar) do
    date_from_iso_days(days, calendar)
  end

  def date_from_iso_days(iso_days, calendar) when is_integer(iso_days) do
    {year, month, day} = calendar.date_from_iso_days(iso_days)
    {:ok, date} = Date.new(year, month, day, calendar)
    date
  end

  def iso_days_to_day_of_week({days, _}, calendar) do
    iso_days_to_day_of_week(days, calendar)
  end

  def iso_days_to_day_of_week(iso_days) when is_integer(iso_days) do
    Integer.mod(iso_days + 5, 7) + 1
  end

  def weekend_starts(%LanguageTag{territory: territory}) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekend_starts(territory)
    end
  end

  def weekend_ends(%LanguageTag{territory: territory}) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekend_ends(territory)
    end
  end

  def first_day(%LanguageTag{territory: territory}) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      first_day(territory)
    end
  end

  def min_days(%LanguageTag{territory: territory}) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      min_days(territory)
    end
  end

  @week_info Cldr.Config.week_info()

  for territory <- Cldr.known_territories() do
    starts =
      get_in(@week_info, [:weekend_start, territory]) ||
        get_in(@week_info, [:weekend_start, @the_world])

    ends =
      get_in(@week_info, [:weekend_end, territory]) ||
        get_in(@week_info, [:weekend_end, @the_world])

    first_day =
      get_in(@week_info, [:first_day, territory]) ||
        get_in(@week_info, [:first_day, @the_world])

    min_days =
      get_in(@week_info, [:min_days, territory]) ||
        get_in(@week_info, [:min_days, @the_world])

    def weekend_starts(unquote(territory)) do
      unquote(starts)
    end

    def weekend_ends(unquote(territory)) do
      unquote(ends)
    end

    def first_day(unquote(territory)) do
      unquote(first_day)
    end

    def min_days(unquote(territory)) do
      unquote(min_days)
    end

    def weekend(unquote(territory)) do
      unquote(Enum.to_list(starts..ends))
    end

    def weekdays(unquote(territory)) do
      unquote(@days -- Enum.to_list(starts..ends))
    end
  end

  def weekend_starts(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekend_starts(territory)
    end
  end

  def weekend_ends(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekend_ends(territory)
    end
  end

  def first_day(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      first_day(territory)
    end
  end

  def min_days(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      min_days(territory)
    end
  end

  def weekend(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekend(territory)
    end
  end

  def weekdays(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekdays(territory)
    end
  end

  # At least 6 months of the year are in the beginning year
  def beginning_gregorian_year(year, %Config{anchor: :first, year: :majority, month: month})
      when month > 6 do
    year - 1
  end

  def beginning_gregorian_year(year, %Config{anchor: :first, year: :ending}) do
    year - 1
  end

  def ending_gregorian_year(year, %Config{anchor: :first, year: :ending}) do
    year
  end

  # The year is defined as the beginning year
  def ending_gregorian_year(year, %Config{anchor: :first, year: :majority, month: month})
      when month > 6 do
    year
  end

  # The year is defined as the beginning year
  def ending_gregorian_year(year, %Config{anchor: :last, year: :beginning}) do
    year
  end

  # At least 6 months of the year are in the beginning year
  def ending_gregorian_year(year, %Config{anchor: :last, year: :majority, month: month})
      when month > 6 do
    year
  end

  # At least 6 months are in the next gregorian year so thats
  # the ending year
  def ending_gregorian_year(year, %Config{anchor: :last, year: :majority}) do
    year + 1
  end

  # If the ending month is 12 then the entire year is the same
  # gregorian year
  def ending_gregorian_year(year, %Config{anchor: :last, month: 12}) do
    year
  end

  # The ending month extends into the next year. Therefore
  # the ending year is next gregorian year
  def ending_gregorian_year(year, %Config{anchor: :last, year: :ending}) do
    year + 1
  end

  @doc """
  Returns the number of days in `n` weeks

  ## Example

      iex> Cldr.Calendar.weeks_to_days(2)
      14

  """
  @spec weeks_to_days(integer) :: integer
  def weeks_to_days(n) do
    n * @days_in_a_week
  end

  @doc false
  def calendar_error(calendar_name) do
    {Cldr.UnknownCalendarError, "The calendar #{inspect(calendar_name)} is not known."}
  end

  @doc false
  def extract_options(options) do
    backend = Keyword.get(options, :backend)
    locale = Keyword.get(options, :locale, Cldr.get_locale())
    calendar = Keyword.get(options, :calendar)
    anchor = Keyword.get(options, :anchor, :first)
    weeks_in_month = Keyword.get(options, :weeks_in_month, {4, 5, 4})
    year = Keyword.get(options, :year, :majority)
    month = Keyword.get(options, :month, 1)
    {min_days, day} = min_and_first_days(locale, options)

    %Config{
      min_days: min_days,
      day: day,
      month: month,
      year: year,
      backend: backend,
      calendar: calendar,
      anchor: anchor,
      weeks_in_month: weeks_in_month
    }
  end

  defp min_and_first_days(locale, options) do
    min_days = Keyword.get(options, :min_days, min_days(locale))
    first_day = Keyword.get(options, :day, first_day(locale))
    {min_days, first_day}
  end

  def offset_to_string(utc, std, zone, format \\ :extended)
  def offset_to_string(0, 0, "Etc/UTC", _format), do: "Z"

  def offset_to_string(utc, std, _zone, format) do
    total = utc + std
    second = abs(total)
    minute = second |> rem(3600) |> div(60)
    hour = div(second, 3600)
    format_offset(total, hour, minute, format)
  end

  def format_offset(total, hour, minute, :extended) do
    sign(total) <> zero_pad(hour, 2) <> ":" <> zero_pad(minute, 2)
  end

  def format_offset(total, hour, minute, :basic) do
    sign(total) <> zero_pad(hour, 2) <> zero_pad(minute, 2)
  end

  def zone_to_string(0, 0, _abbr, "Etc/UTC"), do: ""
  def zone_to_string(_, _, abbr, zone), do: " " <> abbr <> " " <> zone

  def sign(total) when total < 0, do: "-"
  def sign(_), do: "+"

  def zero_pad(val, count) when val >= 0 do
    num = Integer.to_string(val)
    :binary.copy("0", max(count - byte_size(num), 0)) <> num
  end

  def zero_pad(val, count) do
    "-" <> zero_pad(-val, count)
  end

  defdelegate day_of_week(date), to: Date
  defdelegate quarter_of_year(date), to: Date
  defdelegate days_in_month(date), to: Date
  defdelegate day_of_era(date), to: Date
  defdelegate day_of_year(date), to: Date
  defdelegate months_in_year(date), to: Date
end
