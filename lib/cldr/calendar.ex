defmodule Cldr.Calendar do
  @callback week_of_year(Calendar.year(), Calendar.month(), Calendar.day(), Keyword.t()) ::
              {Calendar.year(), Calendar.week()}
  @callback iso_week_of_year(Calendar.year(), Calendar.month(), Calendar.day()) ::
              {Calendar.year(), Calendar.week()}

  @type day_of_the_week :: 1..7
  @type day_names :: :monday | :tuesday | :wednesday | :thursday | :friday | :saturday | :sunday
  @type date_or_time :: Date.t() | NaiveDateTime.t() | IsoDay.t() | map()

  @days [1, 2, 3, 4, 5, 6, 7]
  @days_in_a_week Enum.count(@days)
  @the_world :"001"

  alias Cldr.LanguageTag

  @doc false
  def cldr_backend_provider(config) do
    Cldr.Calendar.Backend.Compiler.define_calendar_modules(config)
  end

  defdelegate day_of_week(date), to: Date
  defdelegate quarter_of_year(date), to: Date
  defdelegate days_in_month(date), to: Date
  defdelegate day_of_era(date), to: Date
  defdelegate day_of_year(date), to: Date
  defdelegate months_in_year(date), to: Date

  def iso_week_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.iso_week_of_year(year, month, day)
  end

  def week_of_year(date, options \\ []) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.week_of_year(year, month, day, options)
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

  def date_from_iso_days(days, calendar) do
    {year, month, day} = calendar.date_from_iso_days(days)
    {:ok, date} = Date.new(year, month, day, calendar)
    date
  end

  def iso_days_to_day_of_week(iso_days) do
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

  def weekend_starts(territory) when is_binary(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekend_starts(territory)
    end
  end

  def weekend_ends(territory) when is_binary(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekend_ends(territory)
    end
  end

  def first_day(territory) when is_binary(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      first_day(territory)
    end
  end

  def min_days(territory) when is_binary(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      min_days(territory)
    end
  end

  def weekend(territory) when is_binary(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekend(territory)
    end
  end

  def weekdays(territory) when is_binary(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekdays(territory)
    end
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
end
