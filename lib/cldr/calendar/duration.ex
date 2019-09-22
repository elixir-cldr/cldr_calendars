defmodule Cldr.Calendar.Duration do
  @moduledoc """
  Functions to create and format a difference between
  two dates, times or datetimes.

  The difference between two dates (or times or datetimes) is
  usually defined in terms of days or seconds.

  A duration is calculated as the difference in time in calendar
  units: years, months, days, hours, minutes, seconds and microseconds.

  This is useful to support formatting a string for users in
  easy-to-understand terms. For example `11 months, 3 days and 4 minutes`
  is a lot easier to understand than `28771440` seconds.

  The package [ex_cldr_units](https://hex.pm/packages/ex_cldr_units) can
  be optionally configured to provide localized formatting of durations.

  If configured, the following providers should be configured in the
  appropriate CLDR backend module. For example:

  ```elixir
  defmodule MyApp.Cldr do
    use Cldr,
      locales: ["en", "ja"],
      providers: [Cldr.Calendar, Cldr.Number, Cldr.Unit, Cldr.List]
  end
  ```

  """

  @struct_list [year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, microsecond: 0]
  @keys Keyword.keys(@struct_list)
  defstruct @struct_list

  @typedoc "Measure a duration in calendar units"
  @type t :: %__MODULE__{
          year: non_neg_integer(),
          month: non_neg_integer(),
          day: non_neg_integer(),
          hour: non_neg_integer(),
          minute: non_neg_integer(),
          second: non_neg_integer(),
          microsecond: non_neg_integer()
        }

  @typedoc "A date, time or datetime"
  @type date_or_datetime ::
          Calendar.date() | Calendar.time() | Calendar.datetime() | Calendar.naive_datetime()

  @microseconds_in_second 1_000_000
  @microseconds_in_day 86_400_000_000

  defimpl String.Chars do
    def to_string(duration) do
      Cldr.Calendar.Duration.to_string!(duration)
    end
  end

  if Code.ensure_loaded?(Cldr.Unit) do
    @doc """
    Returns a string formatted representation of
    a duration.

    Note that time units that are zero are ommitted
    from the output.

    Formatting is

    ## Arguments

    * `duration` is a duration of type `t()` returned
      by `Cldr.Calendar.Duration.new/2`

    * `options` is a Keyword list of options

    ## Options

    * `:except` is a list of time units to be omitted from
      the formatted output. It may be useful to use
      `except: [:microsecond]` for example. The default is
      `[]`.

    * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`
      or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/2`
      The default is `Cldr.get_locale/0`

    * `backend` is any module that includes `use Cldr` and therefore
      is a `Cldr` backend module. The default is `Cldr.default_backend/0`

    * `:list_options` is a list of options passed to `Cldr.List.to_string/3` to
      control the final list output.

    Any other options are passed to `Cldr.Number.to_string/3` and
    `Cldr.Unit.to_string/3` during the formatting process.

    ## Example

        iex> {:ok, duration} = Cldr.Calendar.Duration.new(~D[2019-01-01], ~D[2019-12-31])
        iex> Cldr.Calendar.Duration.to_string(duration)
        {:ok, "11 months and 30 days"}

    """
    def to_string(%__MODULE__{} = duration, options \\ []) do
      {except, options} = Keyword.pop(options, :except, [])

      for key <- @keys, value = Map.get(duration, key), value != 0 && key not in except do
        Cldr.Unit.new(key, value)
      end
      |> Cldr.Unit.to_string(options)
    end
  else
    @doc """
    Returns a string formatted representation of
    a duration.

    Note that time units that are zero are ommitted
    from the output.

    ## Localized formatting

    If localized formatting of a duration is desired,
    add `{:ex_cldr_units, "~> 2.0"}` to your `mix.exs`
    and ensure you have configured your providers in
    your backend configuration to include: `providers:
    [Cldr.Calendar, Cldr.Number, Cldr.Unit, Cldr.List]`

    ## Arguments

    * `duration` is a duration of type `t()` returned
      by `Cldr.Calendar.Duration.new/2`

    * `options` is a Keyword list of options

    ## Options

    * `:except` is a list of time units to be omitted from
      the formatted output. It may be useful to use
      `except: [:microsecond]` for example. The default is
      `[]`.

    ## Example

        iex> {:ok, duration} = Cldr.Calendar.Duration.new(~D[2019-01-01], ~D[2019-12-31])
        iex> Cldr.Calendar.Duration.to_string(duration)
        {:ok, "11 months, 30 days"}

    """
    def to_string(%__MODULE__{} = duration, options \\ []) do
      except = Keyword.get(options, :except, [])

      formatted =
        for key <- @keys, value = Map.get(duration, key), value != 0 && key not in except do
          if value > 1, do: "#{value} #{key}s", else: "#{value} #{key}"
        end
        |> Enum.join(", ")

      {:ok, formatted}
    end
  end

  @doc """
  Formats a duration as a string or raises
  an exception on error.

  ## Arguments

  * `duration` is a duration of type `t()` returned
    by `Cldr.Calendar.Duration.new/2`

  * `options` is a Keyword list of options

  ## Options

  See `Cldr.Calendar.Duration.to_string/2`

  ## Returns

  * A formatted string or

  * raises an exception

  """

  @spec to_string!(t(), Keyword.t()) :: String.t() | no_return
  def to_string!(%__MODULE__{} = duration, options \\ []) do
    case to_string(duration, options) do
      {:ok, string} -> string
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  @doc """
  Calculates the calendar difference between two dates
  returning a `Duration` struct.

  The difference calculated is in terms of years, months,
  days, hours, minutes, seconds and microseconds.

  ## Arguments

  * `from` is a date, time or datetime representing the
    start of the duration

  * `to` is a date, time or datetime representing the
    end of the duration

  Note that `from` must be before or at the same time
  as `to`. In addition, both `from` and `to` must
  be in the same calendar.

  ## Returns

  * A `{:ok, duration struct}` tuple or a

  * `{:error, {exception, reason}}` tuple

  ## Example

      iex> Cldr.Calendar.Duration.new(~D[2019-01-01], ~D[2019-12-31])
      {:ok,
       %Cldr.Calendar.Duration{
         year: 0,
         month: 11,
         day: 30,
         hour: 0,
         microsecond: 0,
         minute: 0,
         second: 0
       }}

  """

  @spec new(from :: date_or_datetime(), to :: date_or_datetime()) ::
          {:ok, t()} | {:error, {module(), String.t()}}

  def new(%{calendar: calendar} = from, %{calendar: calendar} = to) do
    time_diff = time_duration(from, to)
    date_diff = date_duration(from, to)

    duration =
      if time_diff < 0 do
        back_one_day(date_diff, calendar) |> merge(@microseconds_in_day + time_diff)
      else
        date_diff |> merge(time_diff)
      end

    {:ok, duration}
  end

  def new(%{calendar: _calendar1} = from, %{calendar: _calendar2} = to) do
    {:error,
     {Cldr.IncompatibleCalendarError,
      "The two dates must be in the same calendar. Found #{inspect(from)} and #{inspect(to)}"}}
  end

  @doc """
  Calculates the calendar difference between two dates
  returning a `Duration` struct.

  The difference calculated is in terms of years, months,
  days, hours, minutes, seconds and microseconds.

  ## Arguments

  * `from` is a date, time or datetime representing the
    start of the duration

  * `to` is a date, time or datetime representing the
    end of the duration

  Note that `from` must be before or at the same time
  as `to`. In addition, both `from` and `to` must
  be in the same calendar.

  ## Returns

  * A `duration` struct or

  * raises an exception

  ## Example

      iex> Cldr.Calendar.Duration.new!(~D[2019-01-01], ~D[2019-12-31])
      %Cldr.Calendar.Duration{
        year: 0,
        month: 11,
        day: 30,
        hour: 0,
        microsecond: 0,
        minute: 0,
        second: 0
      }

  """

  @spec new!(from :: date_or_datetime(), to :: date_or_datetime()) ::
          t() | no_return()

  def new!(from, to) do
    case new(from, to) do
      {:ok, duration} -> duration
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  defp time_duration(
         %{hour: _, minute: _, second: _, microsecond: _, calendar: calendar} = from,
         %{hour: _, minute: _, second: _, microsecond: _, calendar: calendar} = to
       ) do
    Time.diff(to, from, :microsecond)
  end

  defp time_duration(_to, _from) do
    0
  end

  defp date_duration(
         %{year: year, month: month, day: day, calendar: calendar},
         %{year: year, month: month, day: day, calendar: calendar}
       ) do
    %__MODULE__{}
  end

  defp date_duration(%{calendar: calendar} = from, %{calendar: calendar} = to) do
    if Date.compare(from, to) in [:gt] do
      raise ArgumentError, "`from` date must be before or equal to `to` date"
    end

    %{year: year1, month: month1, day: day1} = from
    %{year: year2, month: month2, day: day2} = to

    # Doesnt account for era in calendars like Japanese
    year_diff = year2 - year1 - possible_adjustment(month2, month1, day2, day1)

    month_diff =
      if month2 > month1 do
        month2 - month1 - possible_adjustment(day2, day1)
      else
        calendar.months_in_year(year1) - month1 + month2 - possible_adjustment(day2, day1)
      end

    day_diff =
      if day2 > day1 do
        day2 - day1
      else
        calendar.days_in_month(year1, month1) - day1 + day2
      end

    %__MODULE__{year: year_diff, month: month_diff, day: day_diff}
  end

  defp back_one_day(date_diff, calendar) do
    back_one_day(date_diff, :day, calendar)
  end

  defp back_one_day(%{day: day} = date_diff, :day, calendar) do
    %{date_diff | day: day - 1}
    |> back_one_day(:month, calendar)
  end

  defp back_one_day(%{month: month, day: day} = date_diff, :month, calendar) when day < 1 do
    %{date_diff | month: month - 1}
    |> back_one_day(:year, calendar)
  end

  defp back_one_day(%{year: _, month: _, day: _} = date_diff, :month, _calendar) do
    date_diff
  end

  defp back_one_day(%{year: year, month: month} = date_diff, :year, calendar) when month < 1 do
    diff = %{date_diff | year: year - 1}
    diff = if diff.month < 1, do: %{diff | month: calendar.months_in_year(year)}, else: diff

    diff =
      if diff.day < 1, do: %{diff | day: calendar.days_in_month(year, diff.month)}, else: diff

    diff
  end

  defp back_one_day(%{year: _, month: _, day: _} = date_diff, :year, _calendar) do
    date_diff
  end

  defp merge(duration, microseconds) do
    {seconds, microseconds} = Cldr.Math.div_mod(microseconds, @microseconds_in_second)
    {hours, minutes, seconds} = :calendar.seconds_to_time(seconds)

    duration
    |> Map.put(:hour, hours)
    |> Map.put(:minute, minutes)
    |> Map.put(:second, seconds)
    |> Map.put(:microsecond, microseconds)
  end

  # The difference in years is adjusted if the
  # month of the `to` year is less than the
  # month of the `from` year
  defp possible_adjustment(m2, m1, _d2, _d1) when m2 < m1, do: 1
  defp possible_adjustment(m2, m2, d2, d1) when d2 < d1, do: 1
  defp possible_adjustment(_m2, _m1, _d2, _d1), do: 0

  defp possible_adjustment(m2, m1) when m2 < m1, do: 1
  defp possible_adjustment(_m2, _m1), do: 0
end
