defmodule Cldr.Calendar.Interval do
  @moduledoc """
  Implements functions to return intervals and compare
  date intervals.

  In particular it provides functions which return an
  interval (as a `Date.Range.t`) for years, quarters,
  months, weeks and days.
  """

  @doc """
  Returns a `Date.Range.t` that represents
  the `year`.

  The range is enumerable.

  ## Arguments

  * `year` is any `year` for `calendar`

  * `calendar` is any module that implements
    the `Calendar` and `Cldr.Calendar`
    behaviours. The default is `Cldr.Calendar.Gregorian`.

  ## Returns

  * A `Date.Range.t()` representing the
    the enumerable days in the `year`

  ## Examples

      iex> Cldr.Calendar.Interval.year 2019, Cldr.Calendar.UK
      #DateRange<%Date{calendar: Cldr.Calendar.UK, day: 1, month: 1, year: 2019}, %Date{calendar: Cldr.Calendar.UK, day: 31, month: 12, year: 2019}>

      iex> Cldr.Calendar.Interval.year 2019, Cldr.Calendar.NRF
      #DateRange<%Date{calendar: Cldr.Calendar.NRF, day: 1, month: 1, year: 2019}, %Date{calendar: Cldr.Calendar.NRF, day: 7, month: 52, year: 2019}>

  """
  @spec year(Calendar.year(), Cldr.Calendar.calendar()) :: Date.Range.t()
  @spec year(Date.t()) :: Date.Range.t()

  def year(%{year: _, month: _, day: _} = date) do
    year(date.year, date.calendar)
  end

  def year(year, calendar \\ Cldr.Calendar.Gregorian) do
    calendar.year(year)
  end

  @doc """
  Returns a `Date.Range.t` that represents
  the `quarter`.

  The range is enumerable.

  ## Arguments

  * `year` is any `year` for `calendar`

  * `quarter` is any `quarter` in the
  `  year` for `calendar`

  * `calendar` is any module that implements
    the `Calendar` and `Cldr.Calendar`
    behaviours. The default is `Cldr.Calendar.Gregorian`.

  ## Returns

  * A `Date.Range.t()` representing the
    the enumerable days in the `quarter`

  ## Examples

      iex> Cldr.Calendar.Interval.quarter 2019, 2, Cldr.Calendar.UK
      #DateRange<%Date{calendar: Cldr.Calendar.UK, day: 1, month: 4, year: 2019}, %Date{calendar: Cldr.Calendar.UK, day: 30, month: 6, year: 2019}>

      iex> Cldr.Calendar.Interval.quarter 2019, 2, Cldr.Calendar.ISOWeek
      #DateRange<%Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 14, year: 2019}, %Date{calendar: Cldr.Calendar.ISOWeek, day: 7, month: 26, year: 2019}>

  """
  @spec quarter(Calendar.year(), Cldr.Calendar.quarter(), Cldr.Calendar.calendar()) :: Date.Range.t()
  @spec quarter(Date.t()) :: Date.Range.t()

  def quarter(date) do
    quarter = Cldr.Calendar.quarter_of_year(date)
    quarter(date.year, quarter, date.calendar)
  end

  def quarter(year, quarter, calendar \\ Cldr.Calendar.Gregorian) do
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
    behaviours. The default is `Cldr.Calendar.Gregorian`.

  ## Returns

  * A `Date.Range.t()` representing the
    the enumerable days in the `month`

  ## Examples

      iex> Cldr.Calendar.Interval.month 2019, 3, Cldr.Calendar.UK
      #DateRange<%Date{calendar: Cldr.Calendar.UK, day: 1, month: 3, year: 2019}, %Date{calendar: Cldr.Calendar.UK, day: 30, month: 3, year: 2019}>

      iex> Cldr.Calendar.Interval.month 2019, 3, Cldr.Calendar.US
      #DateRange<%Date{calendar: Cldr.Calendar.US, day: 1, month: 3, year: 2019}, %Date{calendar: Cldr.Calendar.US, day: 31, month: 3, year: 2019}>

  """
  @spec month(Calendar.year(), Calendar.month(), Cldr.Calendar.calendar()) :: Date.Range.t()
  @spec month(Date.t()) :: Date.Range.t()

  def month(date) do
    month = Cldr.Calendar.month_of_year(date)
    month(date.year, month, date.calendar)
  end

  def month(year, month, calendar \\ Cldr.Calendar.Gregorian) do
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
    behaviours. The default is `Cldr.Calendar.Gregorian`.

  ## Returns

  * A `Date.Range.t()` representing the
    the enumerable days in the `week` or

  * `{:error, :not_defined}` if the calendar
    does not support the concept of weeks

  ## Examples

      iex> Cldr.Calendar.Interval.week 2019, 52, Cldr.Calendar.US
      #DateRange<%Date{calendar: Cldr.Calendar.US, day: 22, month: 12, year: 2019}, %Date{calendar: Cldr.Calendar.US, day: 28, month: 12, year: 2019}>

      iex> Cldr.Calendar.Interval.week 2019, 52, Cldr.Calendar.NRF
      #DateRange<%Date{calendar: Cldr.Calendar.NRF, day: 1, month: 52, year: 2019}, %Date{calendar: Cldr.Calendar.NRF, day: 7, month: 52, year: 2019}>

      iex> Cldr.Calendar.Interval.week 2019, 52, Cldr.Calendar.ISOWeek
      #DateRange<%Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 52, year: 2019}, %Date{calendar: Cldr.Calendar.ISOWeek, day: 7, month: 52, year: 2019}>

      iex> Cldr.Calendar.Interval.week 2019, 52, Cldr.Calendar.Julian
      {:error, :not_defined}

  """
  @spec week(Calendar.year(), Cldr.Calendar.week(), Cldr.Calendar.calendar()) :: Date.Range.t()
  @spec week(Date.t()) :: Date.Range.t()

  def week(date) do
    {year, week} = Cldr.Calendar.week_of_year(date)
    week(year, week, date.calendar)
  end

  def week(year, week, calendar \\ Cldr.Calendar.Gregorian) do
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
    behaviours. The default is `Cldr.Calendar.Gregorian`.

  ## Returns

  * A `Date.Range.t()` representing the
    the enumerable days in the `week`

  ## Examples

      iex> Cldr.Calendar.Interval.day 2019, 52, Cldr.Calendar.US
      #DateRange<%Date{calendar: Cldr.Calendar.US, day: 21, month: 2, year: 2019}, %Date{calendar: Cldr.Calendar.US, day: 21, month: 2, year: 2019}>

      iex> Cldr.Calendar.Interval.day 2019, 92, Cldr.Calendar.NRF
      #DateRange<%Date{calendar: Cldr.Calendar.NRF, day: 1, month: 14, year: 2019}, %Date{calendar: Cldr.Calendar.NRF, day: 1, month: 14, year: 2019}>

      Cldr.Calendar.Interval.day 2019, 8, Cldr.Calendar.ISOWeek
      #DateRange<%Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 2, year: 2019}, %Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 2, year: 2019}>

  """
  @spec day(Calendar.year(), Calendar.day(), Cldr.Calendar.calendar()) :: Date.Range.t()
  @spec day(Date.t()) :: Date.Range.t()

  def day(date) do
    Date.range(date, date)
  end

  def day(year, day, calendar \\ Cldr.Calendar.Gregorian) do
    if day <= calendar.days_in_year(year) do
      iso_days = calendar.first_gregorian_day_of_year(year) + day - 1

      with {year, month, day} = calendar.date_from_iso_days(iso_days),
           {:ok, date} <- Date.new(year, month, day, calendar) do
        day(date)
      end
    else
      {:error, :invalid_date}
    end
  end

  @doc """
  Compare two date ranges.

  Uses [Allen's Interval Algebra](https://en.wikipedia.org/wiki/Allen%27s_interval_algebra)
  to return one of 13 different relationships:

  Relation	     | Converse
  ----------     | --------------
  :precedes	     | :preceded_by
  :meets         | :met_by
  :overlaps      | :overlapped_by
  :finished_by   | :finishes
  :contains      | :during
  :starts        | :started_by
  :equals        | :equals

  ## Arguments

  * `range_1` is a `Date.Range.t`

  * `range_2` is a `Date.Range.t`

  ## Returns

  An atom representing the relationship between the two ranges.

  ## Examples

      iex> Cldr.Calendar.Interval.compare Cldr.Calendar.Interval.day(~D[2019-01-01]), Cldr.Calendar.Interval.day(~D[2019-01-02])
      :meets

      iex> Cldr.Calendar.Interval.compare Cldr.Calendar.Interval.day(~D[2019-01-01]), Cldr.Calendar.Interval.day(~D[2019-01-03])
      :precedes

      iex> Cldr.Calendar.Interval.compare Cldr.Calendar.Interval.day(~D[2019-01-03]), Cldr.Calendar.Interval.day(~D[2019-01-01])
      :preceded_by

      iex> Cldr.Calendar.Interval.compare Cldr.Calendar.Interval.day(~D[2019-01-02]), Cldr.Calendar.Interval.day(~D[2019-01-01])
      :met_by

      iex> Cldr.Calendar.Interval.compare Cldr.Calendar.Interval.day(~D[2019-01-02]), Cldr.Calendar.Interval.day(~D[2019-01-02])
      :equals

  """
  @spec compare(range_1 :: Date.Range.t(), range_2 :: Date.Range.t()) ::
          Cldr.Calendar.interval_relation

  def compare(
        %Date.Range{first_in_iso_days: first, last_in_iso_days: last},
        %Date.Range{first_in_iso_days: first, last_in_iso_days: last}
      ) do
    :equals
  end

  def compare(%Date.Range{} = r1, %Date.Range{} = r2) do
    cond do
      r1.last_in_iso_days - r2.first_in_iso_days < -1 ->
        :precedes

      r1.last_in_iso_days - r2.first_in_iso_days == -1 ->
        :meets

      r1.first_in_iso_days < r2.first_in_iso_days && r1.last_in_iso_days > r2.last_in_iso_days ->
        :contains

      r1.last_in_iso_days == r2.last_in_iso_days && r1.first_in_iso_days < r2.first_in_iso_days ->
        :finished_by

      r1.first_in_iso_days < r2.first_in_iso_days && r1.last_in_iso_days > r2.first_in_iso_days ->
        :overlaps

      r1.first_in_iso_days == r2.first_in_iso_days && r1.last_in_iso_days < r2.last_in_iso_days ->
        :starts

      r2.last_in_iso_days - r1.first_in_iso_days < -1 ->
        :preceded_by

      r2.last_in_iso_days - r1.first_in_iso_days == -1 ->
        :met_by

      r2.last_in_iso_days == r1.last_in_iso_days && r2.first_in_iso_days < r1.first_in_iso_days ->
        :finishes

      r1.first_in_iso_days > r2.first_in_iso_days && r1.last_in_iso_days < r2.last_in_iso_days ->
        :during

      r2.first_in_iso_days == r1.first_in_iso_days && r1.last_in_iso_days > r2.last_in_iso_days->
        :started_by

      r2.last_in_iso_days > r1.first_in_iso_days && r2.last_in_iso_days < r1.last_in_iso_days ->
        :overlapped_by
    end
  end

end