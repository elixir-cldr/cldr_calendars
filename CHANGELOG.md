# Changelog for Cldr Calendars v0.10.0

This is the changelog for Cldr v0.10.0 released on June 15th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

## Breaking changes

* The format produced by inspecting a Date (or DateTime or NaiveDateTime) has changed. The parsing of dates in `sigil_d` (the `~d` sigil) has also changed in order to facilitate roundtrip conversions. Previously a date would inspect as (using the NRF calendar) `~d[2019-W01-1]NRF`. It now inspects as `~d[2019-W01-1 NRF]`.  The same approach is used for all calendars.  See the examples in `Cldr.Calendar.Sigils`. This change is applicable to Elixir 1.10 and later.

## Enhancements

* Implements `inspect_date/4`, `inspect_datetime/11`, `inspect_naive_datetime/8` and `inspect_time/5` for all `Cldr.Calendar` calendars.  This implementation supports the revised `Inspect` protocol implementation for `Date`, `Time`, `DateTime` and `NaiveDateTime` structs.  The purpose of that change is to allow customer calendars to be inspected. This change is applicable to Elixir 1.10 and later.

* Adds `Cldr.Calendar.week_of_month/1` and `Cldr.Calendar` callback `week_of_month/4` to return the week of a month. The weeks are calculated on the basis of the calendar configuration. As a result, the week of the month, like the week of the year, may be in a different Gregorian year and month compared to the specified date.

* Adds `Cldr.Calendar.weeks_in_year/1` to return the number of weeks in a year.

* Adds a calendar configuration where weeks start on the first day of the year. This configuration is valid only for `:month` based calendars.  The configuration option `day: :first` triggers this behaviour. This configuration can result in the last week of the year being less than 7 days.

* Adds `Cldr.Calendar.inspect/2` that can be used as an `:inspect_fun` option in `Inspect.Opts` for Elixir version 1.9.  It will not be required for Elixir 1.10 and later since [this commit](https://github.com/elixir-lang/elixir/commit/23a68035be96717ca5f8fd20355bdb7bc5ed38f8) introduces `inspect_*` callbacks for `Date`, `Time`, `DateTime` and `NaiveDateTime`. An `:inspect_fun` can be configured in `IEx` by:

```elixir
iex> IEx.configure(inspect: [inspect_fun: &Cldr.Calendar.inspect/2])
:ok
```

## Bug Fixes

* Ensure that `Cldr.Calendar` callbacks return a `Calendar.ISO` calendar if called with one (either as part of a date or as a separate argument).

* Ensure the return calendar types of a an Interval are `Calendar.ISO` is the date provided is `Calendar.ISO`

# Changelog for Cldr Calendars v0.9.0

This is the changelog for Cldr v0.9.0 released on June 9th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

## Breaking changes

* Depends on Elixir 1.8 and above since it requires recent `Calendar` functionality.

# Changelog for Cldr Calendars v0.8.0

This is the changelog for Cldr v0.8.0 released on June 8th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

## Enhancements

* Adds option `:type` to `Cldr.Calendar.localize/3`. This determines the format type to be localized. The valid types are `:format` (the default) or `:stand_alone`.

* Add `Cldr.Calendar.day_periods/2` to support localization of the day periods of a time

* Add `Cldr.Calendar.default_calendar/0`. Returns `Cldr.Calendar.Gregorian`

* Add `Cldr.Calendar.default_cldr_calendar/0`. Returns `:gregorian`

# Changelog for Cldr Calendars v0.7.0

This is the changelog for Cldr v0.7.0 released on June 1st, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Breaking Changes

* Moved `year/1`, `quarter/1`, `month/1`, `week/1` and `day/1` to a new module `Cldr.Calendar.Interval`

### Enhancements

* Adds `Cldr.Calendar.Interval.compare/2` to compare two intervals (date ranges) using [Allen's Interval Algebra](https://en.wikipedia.org/wiki/Allen%27s_interval_algebra) taxonomy.

* Defaults the calendar to `Cldr.Calendar.Gregorian` for `Cldr.Calendar.Interval.year/2`, `Cldr.Calendar.Interval.quarter/3`, `Cldr.Calendar.Interval.month/3`, `Cldr.Calendar.Interval.week/3` and `Cldr.Calendar.Interval.day/3`

# Changelog for Cldr Calendars v0.6.0

This is the changelog for Cldr v0.6.0 released on April 28th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Enhancements

* Remove the need for [nimble_csv](https://hex.pm/nimble_csv) as a dependency

# Changelog for Cldr Calendars v0.5.0

This is the changelog for Cldr v0.5.0 released on April 21th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Breaking changes

* `Cldr.Calendar.localize/3` for `:days_of_week` now returns a list of 2-tuples that are of the format `{day_of_week, day_name}`.

### Enhancements

* Add `Cldr.Calendar.localize/6` which localises numbers as part of a date without parameter checking.  This is considered a private implementation for now.

# Changelog for Cldr Calendars v0.4.1

This is the changelog for Cldr v0.4.1 released on April 19th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Bug Fixes

* Fix calculation of `days_in_month` for the last month in long year of a week-based calendar

# Changelog for Cldr Calendars v0.4.0

This is the changelog for Cldr v0.4.0 released on April 19th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Enhancements

* Adds `Cldr.Calendar.interval_stream/3` which returns a stream function that when enumerated generates a list of dates with a specified precision of either `:years`, `:quarters`, `:months`, `:weeks` or `:days`. This function has the same arguments and generates the same results as `Cldr.Calendar.interval/3` except it generates the results lazily.

* Adds `:days_of_week` option to `Cldr.Calendar.localize/3` which returns a list of the localized names of the days of the week in calendar order.

* Adds `calendar_base/0` to identify whether the calendar is week or month based.

### Bug Fixes

* Fix `Cldr.Calendar.day_of_week/1` for week-based calendars

# Changelog for Cldr Calendars v0.3.0

This is the changelog for Cldr v0.3.0 released on April 16th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Enhancements

* Adds `Cldr.Calendar.interval/3` which generates an enumerable list of dates with a specified precision of either `:years`, `:quarters`, `:months`, `:weeks` or `:days`.

### Examples:
```
iex> import Cldr.Calendar.Sigils
Cldr.Calendar.Sigils

iex> d = ~d[2019-01-31]
%Date{calendar: Cldr.Calendar.Gregorian, day: 31, month: 1, year: 2019}

iex> d2 = ~d[2019-05-31]
%Date{calendar: Cldr.Calendar.Gregorian, day: 31, month: 5, year: 2019}

iex> Cldr.Calendar.interval d, 3, :months
[
  %Date{calendar: Cldr.Calendar.Gregorian, day: 28, month: 2, year: 2019},
  %Date{calendar: Cldr.Calendar.Gregorian, day: 31, month: 3, year: 2019},
  %Date{calendar: Cldr.Calendar.Gregorian, day: 30, month: 4, year: 2019}
]

iex> Cldr.Calendar.interval d, d2, :months
[
  %Date{calendar: Cldr.Calendar.Gregorian, day: 31, month: 1, year: 2019},
  %Date{calendar: Cldr.Calendar.Gregorian, day: 28, month: 2, year: 2019},
  %Date{calendar: Cldr.Calendar.Gregorian, day: 31, month: 3, year: 2019},
  %Date{calendar: Cldr.Calendar.Gregorian, day: 30, month: 4, year: 2019},
  %Date{calendar: Cldr.Calendar.Gregorian, day: 31, month: 5, year: 2019}
]
```
# Changelog for Cldr Calendars v0.2.0

This is the changelog for Cldr v0.2.0 released on April 14th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Breaking Changes

* All calendars now return `{year, month, day}` tuples from `date_from_iso_days/1`. Previously in some cases they returned a `Date.t`

* `first_day_of_year/1` and `last_day_of_year/1`, `first_gregorian_day_of_year/1` and `last_gregorian_day_of_year/1` now all return a `Date.t` or an error tuple.  Previously the returned result types were inconsistent.

* Remove `first_gregorian_day_of_year/1` and `last_gregorian_day_of_year/1` from `Cldr.Calendar` callbacks.

### Enhancements

* Adds `Cldr.Calendar.Julian` implementing the Julian calendar. This calendar does not implement `week/2`, `week_of_year/3` or `iso_week_of_year/3`.

### Bug Fixes

* Fixes calculating negative offsets for months in a week-based calendar.  Thanks to @bglusman. Closes #2.

# Changelog for Cldr Calendars v0.1.0

This is the changelog for Cldr v0.1.0 released on April 5th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Enhancements

* Initial release.  See the README for a description of this project.