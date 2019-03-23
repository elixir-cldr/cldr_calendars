defmodule Cldr.Calendar do
  @moduledoc """
  Calendar functions for calendars compatible with
  Elixir's `Calendar` behaviour.

  `Cldr.Calendar` supports the creation of calendars
  that are variations on the proleptic Gregorian
  calendar. It also adds additional functions, defined
  by the `Cldr.Calendar` behaviour, to support these
  derived calendars.

  The common purpose of these derived calendars is
  to support the creation and use of financial year
  calendars that are commonly used in business.

  There are two general types of calendars supported:

  * `month` calendars that mirror the monthly structure
    of the proleptic Gregorian calendar but which are
    deemed to start the year in a month other than January.

  * `week` calendars that are defined to have a 52 week
    structure (53 weeks in a long year). These calendars
    can be configured to start or end on the first, last or
    nearest day to the beginning or end of a Gregorian
    month.  The main intent behind this structure is to
    have each year start and end on the same day of the
    week with a consistent 13-week quarterly structure than
    enables a more straight forware comparison with
    same-period-last-year financial performance.

  ## Creating new calendars

  ### Creating calendars statically

  ### Creating calendars dynamically

  ## Calendar configuration parameters


  """

  alias Cldr.Calendar.Config

  @typedoc """
  Specifies the type of a calendar.

  A calendar is a module that implements
  the `Calendar` and `Cldr.Calendar`
  behaviours.

  """
  @type calendar :: module()

  @typedoc """
  Specifies the type of a calendar

  """
  @type calendar_type :: :month | :week

  @typedoc """
  Soecifies the week of year for a calendar date.

  """
  @type week :: pos_integer()

  @typedoc """
  Represents the number of days since the
  calendar epoch.

  The Calendar epoch is `0000-01-01`
  in the proleptic gregorian calendar.

  """
  @type iso_day_number :: integer()

  @typedoc """
  Specifies the days of the week as integers.

  Days of the week are encoded as the integers `1` through
  `7` with `1` representig Monday and 7 representing Sunday.

  Note that a calendar can be configured to start
  on any day of the week. `day_of_week` is only a
  way of encoding the days as an integer.
  """
  @type day_of_week :: 1..7

  @doc """
  Returns a tuple of `{year, week_in_year}` for a given `year`, `month` or `week`, and `day`
  for a a calendar.

  The `week_in_year` is calculated based upon the calendar configuration.

  """
  @callback week_of_year(Calendar.year(), Calendar.month() | Clde.Calendar.week(), Calendar.day()) ::
              {Calendar.year(), Calendar.week()}

  @doc """
  Returns a tuple of `{year, week_in_year}` for a given `year`, `month` or `week`, and `day`
  for a a calendar.

  The `iso_week_of_year` is calculated based the ISO calendar..

  """
  @callback iso_week_of_year(Calendar.year(), Calendar.month(), Calendar.day()) ::
              {Calendar.year(), Calendar.week()}

  @doc """
  Returns the first day of a calendar year as a gregorian date.

  """
  @callback first_gregorian_day_of_year(Calendar.year()) :: Date.t()

  @doc """
  Returns the last day of a calendar year as a gregorian date.

  """
  @callback last_gregorian_day_of_year(Calendar.year()) :: Date.t()

  @doc """
  Returns a date range representing the days in a
  calendar year.

  """
  @callback year(Calendar.year()) :: Date.Range.t()

  @doc """
  Returns a date range representing the days in a
  given quarter for a calendar year.

  """
  @callback quarter(Calendar.year(), Calendar.quarter()) :: Date.Range.t()

  @doc """
  Returns a date range representing the days in a
  given month for a calendar year.

  """
  @callback month(Calendar.year(), Calendar.month()) :: Date.Range.t()

  @doc """
  Returns a date range representing the days in a
  given week for a calendar year.

  """
  @callback week(Calendar.year(), Cldr.Calendar.week()) :: Date.Range.t()

  @days [1, 2, 3, 4, 5, 6, 7]
  @days_in_a_week Enum.count(@days)
  @the_world :"001"

  alias Cldr.LanguageTag
  alias Cldr.Calendar.Config

  @doc false
  def cldr_backend_provider(config) do
    Cldr.Calendar.Backend.Compiler.define_calendar_modules(config)
  end

  @doc """
  Creates a new calendar based upon the provided configuration.

  If a module exists with the `calendar_module` name then it
  is returned, not recreated.

  ## Arguments

  * `calendar_module` is am atom representing the module
    name of the created calendar.

  * `calendar_type` is an atom of either `:month` or
    :week` indicating whcih type of calendar is to
    be created

  * `config` is a keyword list defining the configuration
    of the calendar.

  ## Returns

  * `{:ok, module}` where `module` is the new calendar
    module that conforms to the `Calendar` and `Cldr.Calendar`
    behaviours

  ## Configuration



  """
  @spec new(atom(), calendar_type(), Keyword.t()) :: {:ok, calendar()} | no_return()

  def new(calendar_module, calendar_type, config)
      when is_atom(calendar_module) and calendar_type in [:week, :month] do
    if Code.ensure_loaded?(calendar_module) do
      {:ok, calendar_module}
    else
      create_calendar(calendar_module, calendar_type, config)
    end
  end

  defp create_calendar(calendar_module, calendar_type, config) do
    calendar_type =
      calendar_type
      |> to_string
      |> String.capitalize

    contents = quote do
      use unquote(Module.concat(Cldr.Calendar.Base, calendar_type)), unquote(config)
    end

    {:module, module, _, :ok} = Module.create(calendar_module, contents, Macro.Env.location(__ENV__))
    {:ok, module}
  end

  @doc """
  Returns the ordinal day number representing
  Monday

  """
  @spec monday :: 1
  def monday, do: 1

  @doc """
  Returns the ordinal day number representing
  Tuesday.

  """
  @spec tuesday :: 2
  def tuesday, do: 2

  @doc """
  Returns the ordinal day number representing
  Wednesday.

  """
  @spec wednesday :: 3
  def wednesday, do: 3

  @doc """
  Returns the ordinal day number representing
  Thursday.

  """
  @spec thursday :: 4
  def thursday, do: 4

  @doc """
  Returns the ordinal day number representing
  Friday.

  """
  @spec friday :: 5
  def friday, do: 5

  @doc """
  Returns the ordinal day number representing
  Saturday.

  """
  @spec saturday :: 6
  def saturday, do: 6

  @doc """
  Returns the ordinal day number representing
  Sunday.

  """
  @spec sunday :: 7
  def sunday, do: 7

  @doc """
  Returns the first date of a `year`
  for a `calendar`.

  """
  @spec first_day_of_year(Calendar.year, calendar()) :: Date.t

  def first_day_of_year(year, calendar) do
    {:ok, date} = Date.new(year, 1, 1, calendar)
    date
  end

  def first_day_of_year(%{year: year, calendar: calendar}) do
    first_day_of_year(year, calendar)
  end

  @doc """
  Returns the last date of a `year`
  for a `calendar`.

  """
  @spec last_day_of_year(Calendar.year, calendar()) :: Date.t

  def last_day_of_year(year, calendar) do
    last_month = calendar.months_in_year(year)
    last_day = calendar.days_in_month(year, last_month)
    {:ok, date} = Date.new(year, last_month, last_day, calendar)
    date
  end

  @doc """
  Returns the first gregorian date of a `year`
  for a `calendar`.

  """
  @spec first_gregorian_day_of_year(Calendar.year, calendar()) :: Date.t

  def first_gregorian_day_of_year(year, calendar) do
    year
    |> calendar.first_gregorian_day_of_year
    |> Calendar.ISO.date_from_iso_days
  end

  @doc """
  Returns the last gregorian date of a `year`
  for a `calendar`.

  """
  @spec last_day_of_year(Calendar.year, calendar()) :: Date.t

  def last_gregorian_day_of_year(year, calendar) do
    year
    |> calendar.last_gregorian_day_of_year
    |> Calendar.ISO.date_from_iso_days
  end

  def last_day_of_year(%{year: year, calendar: calendar}) do
    last_day_of_year(year, calendar)
  end

  @doc """
  Returns the `{year, iso_week_number}`
  for a `date`.

  """
  @spec iso_week_of_year(Date.t) :: {Calendar.year(), week()}
  def iso_week_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.iso_week_of_year(year, month, day)
  end

  @doc """
  Returns the `{year, week_number}`
  for a `date`.

  """
  @spec week_of_year(Date.t) :: {Calendar.year(), week()}

  def week_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.week_of_year(year, month, day)
  end

  @doc """
  Returns whether a given date is a weekend day.

  Weekend days are locale-specific and depend on
  the policies of a given territory (country).

  ## Arguments

  * `date` is any `Date.t()`

  * `options` is a keyword list of options

  ## Options

  * `:locale` is any locale or locale name validated
    by `Cldr.validate_locale/2`.  The default is
    `Cldr.get_locale()` which returns the locale
    set for the current process

  * `:territory` is any valid ISO-3166-2 territory
    that is validated by `Cldr.validate_territory/1`

  * `:backend` is any `Cldr` backend module. See the
    [backend configuration](https://hexdocs.pm/ex_cldr/readme.html#configuration)
    documentation for further information. The default
    is `Cldr.Calendar.Backend.Default` which configures
    only the `en` locale.

  ## Notes

  When identifying which territory context within which
  to determine whether a given day is a weekend or not
  the following order applies:

  * A territory specified by the `:territory` option

  * The territory defined as part of the `:locale` option

  * The territory defined as part of the current processes
    default locale.

  ## Examples

      # The defalt locale for `Cldr` is `en-001` for which
      # the territory is `001` (the world). The weekend
      # for `001` is Saturday and Sunday
      iex> Cldr.Calendar.weekend? ~D[2019-03-23]
      true

      iex> Cldr.Calendar.weekend? ~D[2019-03-23], locale: "en"
      true

      iex> Cldr.Calendar.weekend? ~D[2019-03-23], territory: "IS"
      true

      # In India the official weekend is only Sunday
      iex> Cldr.Calendar.weekend? ~D[2019-03-23], locale: "en-IN", backend: MyApp.Cldr
      false

      # In Israel the weekend starts on Friday
      iex> Cldr.Calendar.weekend? ~D[2019-03-22], locale: "he", backend: MyApp.Cldr
      true

      # As it also does in Saudia Arabia
      iex> Cldr.Calendar.weekend? ~D[2019-03-22], locale: "ar-SA", backend: MyApp.Cldr
      true

      # Sunday is not a weekend day in Saudi Arabia
      iex> Cldr.Calendar.weekend? ~D[2019-03-24], locale: "ar-SA", backend: MyApp.Cldr
      false

  """
  @spec weekend?(Date.t(), Keyword.t()) :: boolean | {:error, {module(), String.t()}}

  def weekend?(date, options \\ []) do
    locale = Keyword.get(options, :locale, Cldr.get_locale())
    backend = Keyword.get(options, :backend, Cldr.default_backend())
    with {:ok, locale} <- Cldr.validate_locale(locale, backend),
        territory = Keyword.get(options, :territory, locale.territory),
        {:ok, territory} <- Cldr.validate_territory(territory) do
      day_of_week(date) in weekend(territory)
    end
  end

  @doc """
  Returns whether a given date is a weekday.

  Weekdays are locale-specific and depend on
  the policies of a given territory (country).

  ## Arguments

  * `date` is any `Date.t()`

  * `options` is a keyword list of options

  ## Options

  * `:locale` is any locale or locale name validated
    by `Cldr.validate_locale/2`.  The default is
    `Cldr.get_locale()` which returns the locale
    set for the current process

  * `:territory` is any valid ISO-3166-2 territory
    that is validated by `Cldr.validate_territory/1`

  * `:backend` is any `Cldr` backend module. See the
    [backend configuration](https://hexdocs.pm/ex_cldr/readme.html#configuration)
    documentation for further information. The default
    is `Cldr.Calendar.Backend.Default` which configures
    only the `en` locale.

  ## Notes

  When identifying which territory context within which
  to determine whether a given day is a weekday or not
  the following order applies:

  * A territory specified by the `:territory` option

  * The territory defined as part of the `:locale` option

  * The territory defined as part of the current processes
    default locale.

  ## Examples

      # The defalt locale for `Cldr` is `en-001` for which
      # the territory is `001` (the world). The weekdays
      # for `001` are Monday to Friday
      iex> Cldr.Calendar.weekday? ~D[2019-03-23], locale: "en"
      false

      iex> Cldr.Calendar.weekday? ~D[2019-03-23], territory: "IS"
      false

      # Saturday is a weekday in India
      iex> Cldr.Calendar.weekday? ~D[2019-03-23], locale: "en-IN", backend: MyApp.Cldr
      true

      # Friday is not a weekday in Saudi Arabia
      iex> Cldr.Calendar.weekday? ~D[2019-03-22], locale: "ar-SA", backend: MyApp.Cldr
      false

      # Friday is not a weekday in Israel
      iex> Cldr.Calendar.weekday? ~D[2019-03-22], locale: "he", backend: MyApp.Cldr
      false

  """
  @spec weekday?(Date.t(), Keyword.t()) :: boolean | {:error, {module(), String.t()}}

  def weekday?(date, options \\ []) do
    locale = Keyword.get(options, :locale, Cldr.get_locale())
    backend = Keyword.get(options, :backend, Cldr.default_backend())
    with {:ok, locale} <- Cldr.validate_locale(locale, backend),
        territory = Keyword.get(options, :territory, locale.territory),
        {:ok, territory} <- Cldr.validate_territory(territory) do
      day_of_week(date) in weekdays(territory)
    end
  end

  @doc """
  Returns a `Date.Range.t` that represents
  the `year`.

  The range is enumerable.

  ## Arguments

  * `year` is any `year` for `calendar`

  * `calendar` is any module that implements
    the `Calendar` and `Cldr.Calendar`
    behaviours

  ## Returns

  * A `Date.Range.t()` representing the
    the enumerable days in the `year`

  ## Examples

      iex> Cldr.Calendar.year 2019, Cldr.Calendar.UK
      #DateRange<%Date{calendar: Cldr.Calendar.UK, day: 1, month: 1, year: 2019}, %Date{calendar: Cldr.Calendar.UK, day: 31, month: 12, year: 2019}>

      iex> Cldr.Calendar.year 2019, Cldr.Calendar.NRF
      #DateRange<%Date{calendar: Cldr.Calendar.NRF, day: 1, month: 1, year: 2019}, %Date{calendar: Cldr.Calendar.NRF, day: 7, month: 52, year: 2019}>

  """
  @spec year(Calendar.year(), calendar()) :: Date.Range.t()

  def year(year, calendar) do
    calendar.year(year)
  end

  @doc """
  Returns a `Date.Range.t` that represents
  the `year`.

  The range is enumerable.

  ## Arguments

  * `year` is any `year` for `calendar`

  * `quarter` is any `quarter` in the
  `  year` for `calendar`

  * `calendar` is any module that implements
    the `Calendar` and `Cldr.Calendar`
    behaviours

  ## Returns

  * A `Date.Range.t()` representing the
    the enumerable days in the `quarter`

  ## Examples

      iex> Cldr.Calendar.quarter 2019, 2, Cldr.Calendar.UK
      #DateRange<%Date{calendar: Cldr.Calendar.UK, day: 1, month: 4, year: 2019}, %Date{calendar: Cldr.Calendar.UK, day: 30, month: 6, year: 2019}>

      iex> Cldr.Calendar.quarter 2019, 2, Cldr.Calendar.ISOWeek
      #DateRange<%Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 14, year: 2019}, %Date{calendar: Cldr.Calendar.ISOWeek, day: 7, month: 26, year: 2019}>

  """
  @spec quarter(Calendar.year(), Calendar.quarter(), calendar()) :: Date.Range.t()

  def quarter(year, quarter, calendar) do
    calendar.quarter(year, quarter)
  end

  @doc """
  Returns a `Date.Range.t` that represents
  the `year`.

  The range is enumerable.

  ## Arguments

  * `year` is any `year` for `calendar`

  * `month` is any `month` in the `year`
    for `calendar`

  * `calendar` is any module that implements
    the `Calendar` and `Cldr.Calendar`
    behaviours

  ## Returns

  * A `Date.Range.t()` representing the
    the enumerable days in the `month`

  ## Examples

      iex> Cldr.Calendar.month 2019, 3, Cldr.Calendar.UK
      #DateRange<%Date{calendar: Cldr.Calendar.UK, day: 1, month: 3, year: 2019}, %Date{calendar: Cldr.Calendar.UK, day: 30, month: 3, year: 2019}>

      iex> Cldr.Calendar.month 2019, 3, Cldr.Calendar.US
      #DateRange<%Date{calendar: Cldr.Calendar.US, day: 1, month: 3, year: 2019}, %Date{calendar: Cldr.Calendar.US, day: 31, month: 3, year: 2019}>

  """
  @spec month(Calendar.year(), Calendar.month(), calendar()) :: Date.Range.t()

  def month(year, month, calendar) do
    calendar.month(year, month)
  end

  @doc """
  Returns a `Date.Range.t` that represents
  the `year`.

  The range is enumerable.

  ## Arguments

  * `year` is any `year` for `calendar`

  * `week` is any `week` in the `year`
    for `calendar`

  * `calendar` is any module that implements
    the `Calendar` and `Cldr.Calendar`
    behaviours

  ## Returns

  * A `Date.Range.t()` representing the
    the enumerable days in the `week`

  ## Examples

      iex> Cldr.Calendar.week 2019, 52, Cldr.Calendar.US
      #DateRange<%Date{calendar: Cldr.Calendar.US, day: 21, month: 12, year: 2020}, %Date{calendar: Cldr.Calendar.US, day: 27, month: 12, year: 2020}>

      iex> Cldr.Calendar.week 2019, 52, Cldr.Calendar.NRF
      #DateRange<%Date{calendar: Cldr.Calendar.NRF, day: 1, month: 52, year: 2019}, %Date{calendar: Cldr.Calendar.NRF, day: 7, month: 52, year: 2019}>

      iex> Cldr.Calendar.week 2019, 52, Cldr.Calendar.ISOWeek
      #DateRange<%Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 52, year: 2019}, %Date{calendar: Cldr.Calendar.ISOWeek, day: 7, month: 52, year: 2019}>

  """
  @spec week(Calendar.year(), Cldr.Calendar.week(), calendar()) :: Date.Range.t()

  def week(year, week, calendar) do
    calendar.week(year, week)
  end

  @doc """
  Returns the number of days since the start
  of the epoch.

  The start of the epoch is the date 0000-01-01.

  ## Argumenets

  * `date` is any `Date.t()`

  ## Returns

  * The integer number of days since the epoch
    for the given `date`.

  ## Example

      iex> Cldr.Calendar.date_to_iso_days ~D[2019-01-01]
      737425

      iex> Cldr.Calendar.date_to_iso_days ~D[0001-01-01]
      366

      iex> Cldr.Calendar.date_to_iso_days ~D[0000-01-01]
      0

  """
  @spec date_to_iso_days(Date.t()) :: iso_day_number()

  def date_to_iso_days(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.date_to_iso_days(year, month, day)
  end

  @doc """
  Returns a date represented by a number of
  days since the start of the epoch.

  The start of the epoch is the date
  `0000-01-01`.

  ## Argumenets

  * `iso_days` is an integer representing the
    number of days since the start of the epoch.

  * `calendar` is any module that implements
    the `Calendar` and `Cldr.Calendar` behaviours

  ## Returns

  * a `Date.t()`

  ## Example

      iex> Cldr.Calendar.date_from_iso_days 737425, Calendar.ISO
      ~D[2019-01-01]

      iex> Cldr.Calendar.date_from_iso_days 366, Calendar.ISO
      ~D[0001-01-01]

      iex> Cldr.Calendar.date_from_iso_days 0, Calendar.ISO
      ~D[0000-01-01]

  """
  @spec date_from_iso_days(Calendar.iso_days | iso_day_number, calendar()) :: Date.t()

  def date_from_iso_days({days, _}, calendar) do
    date_from_iso_days(days, calendar)
  end

  def date_from_iso_days(iso_day_number, calendar) do
    {year, month, day} = Calendar.ISO.date_from_iso_days(iso_day_number)
    with {:ok, date} <- Date.new(year, month, day),
         {:ok, date} <- Date.convert(date, calendar) do
      date
    end
  end

  @doc """
  Returns the day of the week for a given
  `iso_day_number`

  ## Arguments

  * `iso_day_number` is the number of days since the start
    of the epoch.  See `Cldr.Calendar.date_to_iso_days/1`

  ## Returns

  * An integer representing a day of the week where Monday
    is represented by `1` and Sunday is represented by `7`

  ## Examples

      iex> days = Cldr.Calendar.date_to_iso_days ~D[2019-01-01]
      iex> Cldr.Calendar.iso_days_to_day_of_week(days) == Cldr.Calendar.tuesday
      true

  """
  @spec iso_days_to_day_of_week(Calendar.iso_days | iso_day_number, calendar()) :: day_of_week()

  def iso_days_to_day_of_week({days, _}, calendar) do
    iso_days_to_day_of_week(days, calendar)
  end

  def iso_days_to_day_of_week(iso_day_number) when is_integer(iso_day_number) do
    Integer.mod(iso_day_number + 5, 7) + 1
  end

  #
  # Helpers
  #

  defp first_day(%LanguageTag{territory: territory}) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      first_day(territory)
    end
  end

  defp min_days(%LanguageTag{territory: territory}) do
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

    defp first_day(unquote(territory)) do
      unquote(first_day)
    end

    defp min_days(unquote(territory)) do
      unquote(min_days)
    end

    defp weekend(unquote(territory)) do
      unquote(Enum.to_list(starts..ends))
    end

    defp weekdays(unquote(territory)) do
      unquote(@days -- Enum.to_list(starts..ends))
    end
  end

  defp first_day(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      first_day(territory)
    end
  end

  defp min_days(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      min_days(territory)
    end
  end

  defp weekend(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekend(territory)
    end
  end

  defp weekdays(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekdays(territory)
    end
  end

  @doc false
  def beginning_gregorian_year(year, %Config{anchor: :first, year: :majority, month: month})
      when month > 6 do
    year - 1
  end

  def beginning_gregorian_year(year, %Config{anchor: :first, year: :ending}) do
    year - 1
  end

  @doc false
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

  @doc false
  def offset_to_string(utc, std, zone, format \\ :extended)
  def offset_to_string(0, 0, "Etc/UTC", _format), do: "Z"

  def offset_to_string(utc, std, _zone, format) do
    total = utc + std
    second = abs(total)
    minute = second |> rem(3600) |> div(60)
    hour = div(second, 3600)
    format_offset(total, hour, minute, format)
  end

  @doc false
  def format_offset(total, hour, minute, :extended) do
    sign(total) <> zero_pad(hour, 2) <> ":" <> zero_pad(minute, 2)
  end

  def format_offset(total, hour, minute, :basic) do
    sign(total) <> zero_pad(hour, 2) <> zero_pad(minute, 2)
  end

  @doc false
  def zone_to_string(0, 0, _abbr, "Etc/UTC"), do: ""
  def zone_to_string(_, _, abbr, zone), do: " " <> abbr <> " " <> zone

  @doc false
  def sign(total) when total < 0, do: "-"
  def sign(_), do: "+"

  @doc false
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
