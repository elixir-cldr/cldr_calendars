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

  Calendar [starts | ends] on the [last | first] [day] of [month]
  Calendar [starts | ends] on the [day] [nearest to the] [last | first] [day] of [month]

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
  Soecifies the quarter of year for a calendar date.

  """
  @type quarter :: 1..4

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
  @callback week_of_year(Calendar.year(), Calendar.month() | Cldr.Calendar.week(), Calendar.day()) ::
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
  @callback first_gregorian_day_of_year(Calendar.year()) :: integer()

  @doc """
  Returns the last day of a calendar year as a gregorian date.

  """
  @callback last_gregorian_day_of_year(Calendar.year()) :: integer()

  @doc """
  Returns the number of days in a year

  """
  @callback days_in_year(Calendar.year()) :: Calendar.day()

  @doc """
  Returns a date range representing the days in a
  calendar year.

  """
  @callback year(Calendar.year()) :: Date.Range.t()

  @doc """
  Returns a date range representing the days in a
  given quarter for a calendar year.

  """
  @callback quarter(Calendar.year(), Cldr.Calendar.quarter()) :: Date.Range.t()

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

  @doc """
  Increments a `Date.t` or `Date.Range.t` by a specified positive
  or negative integer number of periods (year, quarter, month,
  week or day).

  Calendars need only implement this callback for `:months` and `:quarters`
  since all other date periods can be derived.

  """
  @callback plus(
              Calendar.year(),
              Calendar.month() | Cldr.Calendar.week(),
              Calendar.day(),
              :months,
              integer
            ) :: {Calendar.year(), Calendar.month(), Calendar.day()}

  @callback plus(
              Calendar.year(),
              Calendar.month() | Cldr.Calendar.week(),
              Calendar.day(),
              :quarters,
              integer
            ) :: {Calendar.year(), Calendar.month(), Calendar.day()}

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
    `:week` indicating whcih type of calendar is to
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
      {:already_exists, calendar_module}
    else
      create_calendar(calendar_module, calendar_type, config)
    end
  end

  defp create_calendar(calendar_module, calendar_type, config) do
    structured_config = extract_options(config)

    with {:ok, _} <- validate_config(structured_config, calendar_type) do
      calendar_type =
        calendar_type
        |> to_string
        |> String.capitalize()

      contents =
        quote do
          use unquote(Module.concat(Cldr.Calendar.Base, calendar_type)),
              unquote(Macro.escape(config))
        end

      {:module, module, _, :ok} =
        Module.create(calendar_module, contents, Macro.Env.location(__ENV__))

      {:ok, module}
    end
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

  ## Arguments

  * `year` is any year

  * `calendar` is any module that implements
    the `Calendar` and `Cldr.Calendar`
    behaviours

  ## Returns

  * a `Date.t()` or

  * `{:error, :invalid_date}`

  ## Examples

      iex> Cldr.Calendar.first_day_of_year 2019, Cldr.Calendar.Gregorian
      %Date{calendar: Cldr.Calendar.Gregorian, day: 1, month: 1, year: 2019}

      iex> Cldr.Calendar.first_day_of_year 2019, Cldr.Calendar.NRF
      %Date{calendar: Cldr.Calendar.NRF, day: 1, month: 1, year: 2019}

  """
  @spec first_day_of_year(Calendar.year(), calendar()) :: Date.t()

  def first_day_of_year(year, calendar) do
    with {:ok, date} <- Date.new(year, 1, 1, calendar) do
      date
    end
  end

  def first_day_of_year(%{year: year, calendar: calendar}) do
    first_day_of_year(year, calendar)
  end

  @doc """
  Returns the last date of a `year`
  for a `calendar`.

  ## Arguments

  * `year` is any year

  * `calendar` is any module that implements
    the `Calendar` and `Cldr.Calendar`
    behaviours

  ## Returns

  * a `Date.t()` or

  * `{:error, :invalid_date}`

  ## Examples

      iex> Cldr.Calendar.last_day_of_year 2019, Cldr.Calendar.Gregorian
      %Date{calendar: Cldr.Calendar.Gregorian, day: 31, month: 12, year: 2019}

      iex> Cldr.Calendar.last_day_of_year 2019, Cldr.Calendar.NRF
      %Date{calendar: Cldr.Calendar.NRF, day: 7, month: 52, year: 2019}

  """
  @spec last_day_of_year(Calendar.year(), calendar()) :: Date.t()

  def last_day_of_year(year, calendar) do
    iso_days = calendar.last_gregorian_day_of_year(year)

    with {:ok, date} <- calendar.date_from_iso_days(iso_days) do
      date
    end
  end

  @doc """
  Returns the gregorian date of the first day of of a `year`
  for a `calendar`.

  ## Arguements

  * `year` is any integer year number

  ## Examples

      iex> Cldr.Calendar.first_gregorian_day_of_year 2019, Cldr.Calendar.Gregorian
      {:ok, %Date{calendar: Cldr.Calendar.Gregorian, day: 1, month: 1, year: 2019}}

      iex> Cldr.Calendar.first_gregorian_day_of_year 2019, Cldr.Calendar.NRF
      {:ok, %Date{calendar: Cldr.Calendar.Gregorian, day: 3, month: 2, year: 2019}}

  """
  @spec first_gregorian_day_of_year(Calendar.year(), calendar()) ::
    {:ok, Date.t()} | {:error, :invalid_date}

  def first_gregorian_day_of_year(year, calendar) do
    year
    |> calendar.first_gregorian_day_of_year
    |> Cldr.Calendar.Gregorian.date_from_iso_days()
  end

  @doc """
  Returns the gregorian date of the first day of a `year`
  for a `calendar`.

  ## Arguements

  * `year` is any integer year number

  ## Examples

      iex> Cldr.Calendar.last_gregorian_day_of_year 2019, Cldr.Calendar.Gregorian
      {:ok, %Date{calendar: Cldr.Calendar.Gregorian, day: 31, month: 12, year: 2019}}

      iex> Cldr.Calendar.last_gregorian_day_of_year 2019, Cldr.Calendar.NRF
      {:ok, %Date{calendar: Cldr.Calendar.Gregorian, day: 1, month: 2, year: 2020}}

  """
  @spec last_gregorian_day_of_year(Calendar.year(), calendar()) ::
    {:ok, Date.t()} | {:error, :invalid_date}

  def last_gregorian_day_of_year(year, calendar) do
    year
    |> calendar.last_gregorian_day_of_year
    |> Cldr.Calendar.Gregorian.date_from_iso_days()
  end

  def last_gregorian_day_of_year(%{year: year, calendar: calendar}) do
    last_gregorian_day_of_year(year, calendar)
  end

  @doc """
  Returns the `{day_of_era, era}` for
  a `date`.

  ## Arguments

  * `date` is any `Date.t()`

  ## Returns

  * a the days since the start of the era and
    the era of the year as a tuple

  ## Examples

      iex> Cldr.Calendar.day_of_era ~D[2019-01-01]
      {737060, 1}

      iex> Cldr.Calendar.day_of_era Cldr.Calendar.first_day_of_year(2019, Cldr.Calendar.NRF)
      {737093, 1}

      iex> Cldr.Calendar.day_of_era Cldr.Calendar.last_day_of_year(2019, Cldr.Calendar.NRF)
      {737456, 1}

  """
  @spec day_of_era(Date.t()) :: {Calendar.day(), Calendar.era()}

  def day_of_era(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.day_of_era(year, month, day)
  end

  @doc """
  Returns the `quarter` number for
  a `date`.

  ## Arguments

  * `date` is any `Date.t()`

  ## Returns

  * a the quarter of the year as an
    integer

  ## Examples

      iex> Cldr.Calendar.quarter_of_year ~D[2019-01-01]
      1

      iex> Cldr.Calendar.quarter_of_year Cldr.Calendar.first_day_of_year(2019, Cldr.Calendar.NRF)
      1

      iex> Cldr.Calendar.quarter_of_year Cldr.Calendar.last_day_of_year(2019, Cldr.Calendar.NRF)
      4

  """
  @spec quarter_of_year(Date.t()) :: Cldr.Calendar.quarter()

  def quarter_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.quarter_of_year(year, month, day)
  end

  @doc """
  Returns the `month` number for
  a `date`.

  ## Arguments

  * `date` is any `Date.t()`

  ## Returns

  * a the quarter of the year as an
    integer

  ## Examples

      iex> import Cldr.Calendar.Sigils
      iex> Cldr.Calendar.month_of_year ~d[2019-01-01]
      1
      iex> Cldr.Calendar.month_of_year ~d[2019-12-01]
      12
      iex> Cldr.Calendar.month_of_year ~d[2019-52-01]NRF
      12
      iex> Cldr.Calendar.month_of_year ~d[2019-26-01]NRF
      6

  """
  @spec month_of_year(Date.t()) :: Calendar.month()

  def month_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.month_of_year(year, month, day)
  end

  @doc """
  Returns the `ISO week` number for
  a `date`.

  ## Arguments

  * `date` is any `Date.t()`

  ## Returns

  * a the ISO week of the year as an
    integer

  ## Examples

      iex> import Cldr.Calendar.Sigils
      iex> Cldr.Calendar.iso_week_of_year ~d[2019-01-01]
      {2019, 1}
      iex> Cldr.Calendar.iso_week_of_year ~d[2019-02-01]
      {2019, 5}
      iex> Cldr.Calendar.iso_week_of_year ~d[2019-52-01]NRF
      {2020, 4}
      iex> Cldr.Calendar.iso_week_of_year ~d[2019-26-01]NRF
      {2019, 30}

  """
  @spec iso_week_of_year(Date.t()) :: {Calendar.year(), week()}

  def iso_week_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.iso_week_of_year(year, month, day)
  end

  @doc """
  Returns the `{year, week_number}`
  for a `date`.

  ## Arguments

  * `date` is any `Date.t()`

  ## Returns

  * a the week of the year as an
    integer

  ## Examples

      iex> import Cldr.Calendar.Sigils
      iex> Cldr.Calendar.week_of_year ~d[2019-01-01]
      {2019, 1}
      iex> Cldr.Calendar.week_of_year ~d[2019-12-01]
      {2019, 48}
      iex> Cldr.Calendar.week_of_year ~d[2019-52-01]NRF
      {2019, 52}
      iex> Cldr.Calendar.week_of_year ~d[2019-26-01]NRF
      {2019, 26}

  """
  @spec week_of_year(Date.t()) :: {Calendar.year(), week()}

  def week_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.week_of_year(year, month, day)
  end

  @doc """
  Returns the `day` of the year
  for a `date`.

  ## Arguments

  * `date` is any `Date.t()`

  ## Returns

  * a the day of the year as an
    integer

  ## Examples

      iex> import Cldr.Calendar.Sigils
      iex> Cldr.Calendar.day_of_year ~d[2019-01-01]
      1
      iex> Cldr.Calendar.day_of_year ~d[2016-12-31]
      366
      iex> Cldr.Calendar.day_of_year ~d[2019-12-31]
      365
      iex> Cldr.Calendar.day_of_year ~d[2019-52-07]NRF
      365
      iex> Cldr.Calendar.day_of_year ~d[2012-53-07]NRF
      372

  """
  @spec day_of_year(Date.t()) :: Calendar.day()

  def day_of_year(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.day_of_year(year, month, day)
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
  @spec year(Date.t()) :: Date.Range.t()

  def year(date) do
    year(date.year, date.calendar)
  end

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
  @spec quarter(Calendar.year(), Cldr.Calendar.quarter(), calendar()) :: Date.Range.t()
  @spec quarter(Date.t()) :: Date.Range.t()

  def quarter(date) do
    quarter = quarter_of_year(date)
    quarter(date.year, quarter, date.calendar)
  end

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
  @spec month(Date.t()) :: Date.Range.t()

  def month(date) do
    month = month_of_year(date)
    month(date.year, month, date.calendar)
  end

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
      #DateRange<%Date{calendar: Cldr.Calendar.US, day: 22, month: 12, year: 2019}, %Date{calendar: Cldr.Calendar.US, day: 28, month: 12, year: 2019}>

      iex> Cldr.Calendar.week 2019, 52, Cldr.Calendar.NRF
      #DateRange<%Date{calendar: Cldr.Calendar.NRF, day: 1, month: 52, year: 2019}, %Date{calendar: Cldr.Calendar.NRF, day: 7, month: 52, year: 2019}>

      iex> Cldr.Calendar.week 2019, 52, Cldr.Calendar.ISOWeek
      #DateRange<%Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 52, year: 2019}, %Date{calendar: Cldr.Calendar.ISOWeek, day: 7, month: 52, year: 2019}>

  """
  @spec week(Calendar.year(), Cldr.Calendar.week(), calendar()) :: Date.Range.t()
  @spec week(Date.t()) :: Date.Range.t()

  def week(date) do
    {year, week} = week_of_year(date)
    week(year, week, date.calendar)
  end

  def week(year, week, calendar) do
    calendar.week(year, week)
  end

  @doc """
  Returns a `Date.Range.t` that represents
  the `day`.

  The range is enumerable.

  ## Arguments

  * `year` is any `year` for `calendar`

  * `day` is any `day` in the `year`
    for `calendar`

  * `calendar` is any module that implements
    the `Calendar` and `Cldr.Calendar`
    behaviours

  ## Returns

  * A `Date.Range.t()` representing the
    the enumerable days in the `week`

  ## Examples

      iex> Cldr.Calendar.day 2019, 52, Cldr.Calendar.US
      #DateRange<%Date{calendar: Cldr.Calendar.US, day: 21, month: 2, year: 2019}, %Date{calendar: Cldr.Calendar.US, day: 21, month: 2, year: 2019}>

      iex(6)> Cldr.Calendar.day 2019, 92, Cldr.Calendar.NRF
      #DateRange<%Date{calendar: Cldr.Calendar.NRF, day: 1, month: 14, year: 2019}, %Date{calendar: Cldr.Calendar.NRF, day: 1, month: 14, year: 2019}>

      Cldr.Calendar.day 2019, 8, Cldr.Calendar.ISOWeek
      #DateRange<%Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 2, year: 2019}, %Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 2, year: 2019}>

  """
  @spec day(Calendar.year(), Calendar.day(), calendar()) :: Date.Range.t()
  @spec day(Date.t()) :: Date.Range.t()

  def day(date) do
    Date.range(date, date)
  end

  def day(year, day, calendar) do
    if day <= calendar.days_in_year(year) do
      iso_days = calendar.first_gregorian_day_of_year(year) + day - 1

      with {:ok, date} <- calendar.date_from_iso_days(iso_days) do
        day(date)
      end
    else
      {:error, :invalid_date}
    end
  end

  @doc """
  Returns the current date or date range for
  a date period (year, quarter, month, week
  or day).

  ## Arguments

  * `date_or_date_range` is any `Date.t` or
    `Date.Range.t`

  * `period` is `:year`, `:quarter`, `:month`,
    `:week` or `:day`

  ## Returns

  When a `Date.t` is passed, a `Date.t` is
  returned.  When a `Date.Range.t` is passed
  a `Date.Range.t` is returned.

  ## Examples

  """
  def current(%Date.Range{first: date}, :year) do
    current(date, :year)
    |> year
  end

  def current(date, :year) do
    plus(date, :years, 0)
  end

  def current(%Date.Range{first: date}, :quarter) do
    current(date, :quarter)
    |> quarter
  end

  def current(date, :quarter) do
    plus(date, :quarters, 0)
  end

  def current(%Date.Range{first: date}, :month) do
    current(date, :month)
    |> month
  end

  def current(date, :month) do
    plus(date, :months, 0)
  end

  def current(%Date.Range{first: date}, :week) do
    current(date, :week)
    |> week
  end

  def current(date, :week) do
    plus(date, :weeks, 0)
  end

  def current(%Date.Range{first: date}, :day) do
    current(date, :day)
    |> day
  end

  def current(date, :day) do
    plus(date, :days, 0)
  end

  @doc """
  Returns the nexy date or date range for
  a date period (year, quarter, month, week
  or day).

  ## Arguments

  * `date_or_date_range` is any `Date.t` or
    `Date.Range.t`

  * `period` is `:year`, `:quarter`, `:month`,
  ` :week` or `:day`

  ## Returns

  When a `Date.t` is passed, a `Date.t` is
  returned.  When a `Date.Range.t` is passed
  a `Date.Range.t` is returned.

  ## Examples

  """
  def next(%Date.Range{last: date}, :year) do
    next(date, :year)
    |> year
  end

  def next(date, :year) do
    plus(date, :years, 1)
  end

  def next(%Date.Range{last: date}, :quarter) do
    next(date, :quarter)
    |> quarter
  end

  def next(date, :quarter) do
    plus(date, :quarters, 1)
  end

  def next(%Date.Range{last: date}, :month) do
    next(date, :month)
    |> month
  end

  def next(date, :month) do
    plus(date, :months, 1)
  end

  def next(%Date.Range{last: date}, :week) do
    next(date, :week)
    |> week
  end

  def next(date, :week) do
    plus(date, :weeks, 1)
  end

  def next(%Date.Range{last: date}, :day) do
    next(date, :day)
    |> day
  end

  def next(date, :day) do
    plus(date, :days, 1)
  end

  @doc """
  Returns the previous date or date range for
  a date period (year, quarter, month, week
  or day).

  ## Arguments

  * `date_or_date_range` is any `Date.t` or
    `Date.Range.t`

  * `period` is `:year`, `:quarter`, `:month`,
    `:week` or `:day`

  ## Returns

  When a `Date.t` is passed, a `Date.t` is
  returned.  When a `Date.Range.t` is passed
  a `Date.Range.t` is returned.

  ## Examples

  """
  def previous(%Date.Range{last: date}, :year) do
    previous(date, :year)
    |> year
  end

  def previous(date, :year) do
    plus(date, :years, -1)
  end

  def previous(%Date.Range{last: date}, :quarter) do
    previous(date, :quarter)
    |> quarter
  end

  def previous(date, :quarter) do
    minus(date, :quarters, 1)
  end

  def previous(%Date.Range{last: date}, :month) do
    previous(date, :month)
    |> month
  end

  def previous(date, :month) do
    minus(date, :months, 1)
  end

  def previous(%Date.Range{last: date}, :week) do
    previous(date, :week)
    |> week
  end

  def previous(date, :week) do
    minus(date, :weeks, 1)
  end

  def previous(%Date.Range{last: date}, :day) do
    previous(date, :day)
  end

  def previous(date, :day) do
    minus(date, :days, 1)
  end

  @doc """
  Returns a localized string for a part of
  a `Date.t`.

  ## Arguments

  * `date_` is any `Date.t`

  * `part` is one of `:era`, `:quarter`, `:month`
    or `:day_of_week`

  * `options` is a keyword list of options

  ## Options

  * `:locale` is any valid locale name in the list returned by
    `Cldr.known_locale_names/1` or a `Cldr.LanguageTag` struct
    returned by `Cldr.Locale.new!/2`. The default is `Cldr.get_locale()`.

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module. The default is `Cldr.default_backend/0`.

  * `:format` is one of `:wide`, `:abbreviated` or `:narrow`. The
    default is `:abbreviated`.

  ## Returns

  * A string representing the localized date part, or

  * `{error, {exception_module, message}}` if an error is detected

  ## Examples

      iex> Cldr.Calendar.localize ~D[2019-01-01], :era
      "AD"

      iex> Cldr.Calendar.localize ~D[2019-01-01], :day_of_week
      "Tue"

      iex> Cldr.Calendar.localize ~D[0001-01-01], :day_of_week
      "Mon"

      iex> Cldr.Calendar.localize ~D[2019-06-01], :era
      "AD"

      iex> Cldr.Calendar.localize ~D[2019-06-01], :quarter
      "Q2"

      iex> Cldr.Calendar.localize ~D[2019-06-01], :month
      "Jun"

      iex> Cldr.Calendar.localize ~D[2019-06-01], :day_of_week
      "Sat"

      iex> Cldr.Calendar.localize ~D[2019-06-01], :day_of_week, format: :wide
      "Saturday"

      iex> Cldr.Calendar.localize ~D[2019-06-01], :day_of_week, format: :narrow
      "S"

      iex> Cldr.Calendar.localize ~D[2019-06-01], :day_of_week, locale: "ar"
      "السبت"

  """
  @spec localize(Date.t(), atom(), Keyword.t) :: String.t | {:error, {module(), String.t}}

  def localize(date, part, options \\ [])

  def localize(%{calendar: Calendar.ISO} = date, part, options) do
    date = %{date | calendar: Cldr.Calendar.Gregorian}
    localize(date, part, options)
  end

  def localize(date, part, options) do
    cldr_backend = date.calendar.__config__().cldr_backend
    backend = Keyword.get(options, :backend, cldr_backend || Cldr.default_backend())
    backend = Module.concat(backend, Calendar)
    locale = Keyword.get(options, :locale, Cldr.get_locale())
    format = Keyword.get(options, :format, :abbreviated)

    with {:ok, locale} <- Cldr.validate_locale(locale),
         {:ok, part} <- validate_part(part),
         {:ok, format} <- validate_format(format),
         {:ok, backend} <- validate_backend(backend) do
      localize(date, part, format, backend, locale)
    end
  end

  @doc false
  def localize(date, :era, format, backend, locale) do
    {_, era} = day_of_era(date)

    locale
    |> backend.eras(date.calendar.cldr_calendar_type)
    |> get_in([format, era])
  end

  @doc false
  def localize(date, :quarter, format, backend, locale) do
    quarter = quarter_of_year(date)

    locale
    |> backend.quarters(date.calendar.cldr_calendar_type)
    |> get_in([:format, format, quarter])
  end

  @doc false
  def localize(date, :month, format, backend, locale) do
    month = month_of_year(date)

    locale
    |> backend.months(date.calendar.cldr_calendar_type)
    |> get_in([:format, format, month])
  end

  @doc false
  def localize(date, :day_of_week, format, backend, locale) do
    day = day_of_week(date)

    locale
    |> backend.days(date.calendar.cldr_calendar_type)
    |> get_in([:format, format, day])
  end

  @valid_parts [:era, :quarter, :month, :day_of_week]
  defp validate_part(part) do
    if part in @valid_parts do
      {:ok, part}
    else
      {:error,
       {ArgumentError,
        "The date part #{inspect(part)} is not known. " <>
          "Valid date parts are #{inspect(@valid_parts)}"}}
    end
  end

  @valid_formats [:wide, :abbreviated, :narrow]
  defp validate_format(format) do
    if format in @valid_formats do
      {:ok, format}
    else
      {:error,
       {ArgumentError,
        "The date format #{inspect(format)} is not known. " <>
          "Valid formats are #{inspect(@valid_formats)}"}}
    end
  end

  defp validate_backend(nil) do
    {:error,
     {ArgumentError,
      "No CLDR backend could be found. Please configure a backend. " <>
      "See https://hexdocs.pm/ex_cldr/readme.html#configuration"}}
  end

  defp validate_backend(backend) do
    {:ok, backend}
  end

  @doc """
  Increments a date or date range by an
  integer amount of a date period (year,
  quarter, month, week or day).

  ## Arguments

  * `date_or_date_range` is any `Date.t` or
    `Date.Range.t`

  * `period` is `:year`, `:quarter`, `:month`,
    `:week` or `:day`

  ## Returns

  When a `Date.t` is passed, a `Date.t` is
  returned.  When a `Date.Range.t` is passed
  a `Date.Range.t` is returned.

  ## Examples

  """
  def plus(value, increment) when is_integer(value) and is_integer(increment) do
    value + increment
  end

  @spec plus(Date.t(), atom(), integer()) :: Date.t()
  @spec plus(Date.Range.t(), atom(), integer()) :: Date.Range.t()

  def plus(date, period, days \\ 1)

  def plus(%Date.Range{last: date}, :years, years) do
    plus(date, :years, years)
    |> year
  end

  def plus(date, :years, years) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    new_year = year + years

    new_day =
      new_year
      |> calendar.days_in_month(month)
      |> min(day)

    {:ok, date} = Date.new(new_year, month, new_day, calendar)
    date
  end

  def plus(%Date.Range{last: date}, :quarters, quarters) do
    plus(date, :quarters, quarters)
    |> quarter
  end

  def plus(date, :quarters, quarters) do
    %{year: year, month: month, day: day, calendar: calendar} = date

    calendar.plus(year, month, day, :quarters, quarters)
    |> date_from_tuple(calendar)
  end

  def plus(%Date.Range{last: date}, :months, months) do
    plus(date, :months, months)
    |> month
  end

  def plus(date, :months, months) do
    %{year: year, month: month, day: day, calendar: calendar} = date

    calendar.plus(year, month, day, :months, months)
    |> date_from_tuple(calendar)
  end

  def plus(%Date.Range{last: date}, :weeks, weeks) do
    plus(date, :weeks, weeks)
    |> week
  end

  def plus(%{calendar: calendar} = date, :weeks, weeks) do
    date
    |> date_to_iso_days
    |> plus(weeks_to_days(weeks))
    |> date_from_iso_days(calendar)
  end

  def plus(%Date.Range{last: date}, :days, days) do
    plus(date, :days, days)
    |> day
  end

  def plus(%{calendar: calendar} = date, :days, days) do
    date
    |> date_to_iso_days
    |> plus(days)
    |> date_from_iso_days(calendar)
  end

  @doc """
  Decrements a date or date range by an
  integer amount of a date period (year,
  quarter, month, week or day).

  ## Arguments

  * `date_or_date_range` is any `Date.t` or
    `Date.Range.t`

  * `period` is `:year`, `:quarter`, `:month`,
    `:week` or `:day`

  ## Returns

  When a `Date.t` is passed, a `Date.t` is
  returned.  When a `Date.Range.t` is passed
  a `Date.Range.t` is returned.

  ## Examples

      iex> import Cldr.Calendar.Sigils
      iex> Cldr.Calendar.minus ~d[2016-03-01], :days, 1
      %Date{calendar: Cldr.Calendar.Gregorian, day: 29, month: 2, year: 2016}
      iex> Cldr.Calendar.minus ~d[2019-03-01], :months, 1
      %Date{calendar: Cldr.Calendar.Gregorian, day: 1, month: 2, year: 2019}
      iex> Cldr.Calendar.minus ~d[2016-03-01], :days, 1
      %Date{calendar: Cldr.Calendar.Gregorian, day: 29, month: 2, year: 2016}
      iex> Cldr.Calendar.minus ~d[2019-03-01], :days, 1
      %Date{calendar: Cldr.Calendar.Gregorian, day: 28, month: 2, year: 2019}
      iex> Cldr.Calendar.minus ~d[2019-03-01], :months, 1
      %Date{calendar: Cldr.Calendar.Gregorian, day: 1, month: 2, year: 2019}
      iex> Cldr.Calendar.minus ~d[2019-03-01], :quarters, 1
      %Date{calendar: Cldr.Calendar.Gregorian, day: 1, month: 12, year: 2018}
      iex> Cldr.Calendar.minus ~d[2019-03-01], :years, 1
      %Date{calendar: Cldr.Calendar.Gregorian, day: 1, month: 3, year: 2018}

  """
  def minus(%{calendar: _calendar} = date, period, amount) do
    plus(date, period, -amount)
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
  @spec date_from_iso_days(Calendar.iso_days() | iso_day_number, calendar()) :: Date.t()

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
  Returns a `Date.t` from a date tuple of
  `{year, month, day}` and a calendar.

  ## Arguments

  * `{year, month, day}` is a tuple
    representing a date

  * `calendar` is any module implementing
    the `Calendar` and `Cldr.Calendar`
    behaviours

  ## Returns

  * a `Date.t`

  ## Examples

      iex> Cldr.Calendar.date_from_tuple {2019, 3, 25}, Cldr.Calendar.Gregorian
      %Date{calendar: Cldr.Calendar.Gregorian, day: 25, month: 3, year: 2019}

      iex> Cldr.Calendar.date_from_tuple {2019, 2, 29}, Cldr.Calendar.Gregorian
      {:error, :invalid_date}

  """
  def date_from_tuple({year, month, day}, calendar) do
    with {:ok, date} <- Date.new(year, month, day, calendar) do
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
  @spec iso_days_to_day_of_week(Calendar.iso_days() | Calendar.day()) :: day_of_week()
  def iso_days_to_day_of_week({days, _}) do
    iso_days_to_day_of_week(days)
  end

  def iso_days_to_day_of_week(iso_day_number) when is_integer(iso_day_number) do
    Integer.mod(iso_day_number + 5, 7) + 1
  end

  #
  # Helpers
  #

  def first_day_for_locale(%LanguageTag{territory: territory}) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      first_day_for_locale(territory)
    end
  end

  def min_days_for_locale(%LanguageTag{territory: territory}) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      min_days_for_locale(territory)
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

    def first_day_for_locale(unquote(territory)) do
      unquote(first_day)
    end

    def min_days_for_locale(unquote(territory)) do
      unquote(min_days)
    end

    def weekend(unquote(territory)) do
      unquote(Enum.to_list(starts..ends))
    end

    def weekdays(unquote(territory)) do
      unquote(@days -- Enum.to_list(starts..ends))
    end
  end

  def first_day_for_locale(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      first_day_for_locale(territory)
    end
  end

  def min_days_for_locale(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      min_days_for_locale(territory)
    end
  end

  @doc """
  Returns a list of the days of the week that
  are considered a weekend for a given
  territory (country)

  ## Arguments

  * `territory` is any valid ISO3166-2 code

  ## Returns

  * A list of integers representing the days of
    the week that are weekend days

  ## Examples

      iex> Cldr.Calendar.weekend("US")
      [6, 7]

      iex> Cldr.Calendar.weekend("IN")
      [7]

      iex> Cldr.Calendar.weekend("SA")
      [5, 6]

      iex> Cldr.Calendar.weekend("xx")
      {:error, {Cldr.UnknownTerritoryError, "The territory \\"xx\\" is unknown"}}

  """
  def weekend(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekend(territory)
    end
  end

  @doc """
  Returns a list of the days of the week that
  are considered a weekend for a given
  territory (country)

  ## Arguments

  * `territory` is any valid ISO3166-2 code

  ## Returns

  * A list of integers representing the days of
    the week that are week days

  ## Notes

  The list of days may not my monotonic. See
  the example for Saudi Arabia below.

  ## Examples

      iex> Cldr.Calendar.weekdays("US")
      [1, 2, 3, 4, 5]

      iex> Cldr.Calendar.weekdays("IN")
      [1, 2, 3, 4, 5, 6]

      iex> Cldr.Calendar.weekdays("SA")
      [1, 2, 3, 4, 7]

      iex> Cldr.Calendar.weekdays("xx")
      {:error, {Cldr.UnknownTerritoryError, "The territory \\"xx\\" is unknown"}}

  """
  def weekdays(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      weekdays(territory)
    end
  end

  @doc false

  ## January starts end the same year, December ends starts the same year
  def start_end_gregorian_years(year, %Config{first_or_last: :first, month: 1}) do
    {year, year}
  end

  def start_end_gregorian_years(year, %Config{first_or_last: :last, month: 12}) do
    {year, year}
  end

  ## Majority years
  def start_end_gregorian_years(year, %Config{
        first_or_last: :first,
        year: :majority,
        month: month
      })
      when month <= 6 do
    {year, year + 1}
  end

  def start_end_gregorian_years(year, %Config{
        first_or_last: :first,
        year: :majority,
        month: month
      })
      when month > 6 do
    {year - 1, year}
  end

  def start_end_gregorian_years(year, %Config{first_or_last: :last, year: :majority, month: month})
      when month > 6 do
    {year - 1, year}
  end

  def start_end_gregorian_years(year, %Config{first_or_last: :last, year: :majority, month: month})
      when month <= 6 do
    {year, year + 1}
  end

  ## Beginning years
  def start_end_gregorian_years(year, %Config{first_or_last: :last, year: :beginning}) do
    {year - 1, year}
  end

  ## Ending years
  def start_end_gregorian_years(year, %Config{first_or_last: :first, year: :ending}) do
    {year, year + 1}
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

  def date_to_string(date) do
    %{year: year, month: month, day: day, calendar: calendar} = date
    calendar.date_to_string(year, month, day)
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
    first_or_last = Keyword.get(options, :first_or_last, :first)
    begins_or_ends = Keyword.get(options, :begins_or_ends, :begins)
    weeks_in_month = Keyword.get(options, :weeks_in_month, [4, 5, 4])
    year = Keyword.get(options, :year, :majority)
    month = Keyword.get(options, :month, 1)
    {min_days, day} = min_and_first_days(locale, options)

    %Config{
      min_days: min_days,
      day: day,
      month: month,
      year: year,
      cldr_backend: backend,
      calendar: calendar,
      first_or_last: first_or_last,
      begins_or_ends: begins_or_ends,
      weeks_in_month: weeks_in_month
    }
  end

  defp min_and_first_days(_locale, options) do
    min_days = Keyword.get(options, :min_days, 7)
    first_day = Keyword.get(options, :day, 1)
    {min_days, first_day}
  end

  @valid_weeks_in_month [[4, 4, 5], [4, 5, 4], [5, 4, 4]]
  @valid_year [:majority, :beginning, :ending]
  def validate_config(config, :week) do
    with :ok <- assert(config.day in 1..7, day_error(config.day)),
         :ok <- assert(config.month in 1..12, month_error(config.month)),
         :ok <- assert(config.year in @valid_year, year_error(config.year)),
         :ok <- assert(config.min_days in 1..7, min_days_for_locale_error(config.min_days)),
         :ok <-
           assert(
             config.first_or_last in [:first, :last],
             first_or_last_error(config.first_or_last)
           ),
         :ok <-
           assert(
             config.begins_or_ends in [:begins, :ends],
             begins_or_ends_error(config.begins_or_ends)
           ),
         :ok <-
           assert(
             config.weeks_in_month in @valid_weeks_in_month,
             weeks_in_month_error(config.weeks_in_month)
           ) do
      {:ok, config}
    end
  end

  @doc false
  def validate_config(config, :month) do
    validate_config(config, :week)
  end

  @doc false
  def validate_config!(config, calendar_type) do
    case validate_config(config, calendar_type) do
      {:ok, config} -> config
      {:error, message} -> raise ArgumentError, message
    end
  end

  defp assert(true, _) do
    :ok
  end

  defp assert(false, message) do
    {:error, message}
  end

  defp day_error(day) do
    ":day must be in the range 1..7. Found #{inspect(day)}."
  end

  defp month_error(month) do
    ":month must be in the range 1..12. Found #{inspect(month)}."
  end

  defp year_error(year) do
    ":year must be either :beginning, :ending or :majority. Found #{inspect(year)}."
  end

  def min_days_for_locale_error(min_days) do
    ":min_days must be in the rnage 1..7. Found #{inspect(min_days)}."
  end

  defp first_or_last_error(first_or_last) do
    ":first_or_last must be :first or :last. Found #{inspect(first_or_last)}."
  end

  defp begins_or_ends_error(begins_or_ends) do
    ":begins_or_ends must be :begins or :ends. Found #{inspect(begins_or_ends)}."
  end

  defp weeks_in_month_error(weeks_in_month) do
    ":weeks_in_month must be [4,4,5], [4,5,4] or [5,4,4]. Found #{inspect(weeks_in_month)}"
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
  defdelegate days_in_month(date), to: Date
  defdelegate months_in_year(date), to: Date
end
