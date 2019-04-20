# Changelog for Cldr Calendars v0.5.0

This is the changelog for Cldr v0.5.0 released on April 21th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Breaking changes

* `Cldr.Calendar.localize/3` for `:days_of_week` now returns a list of 2-tuples that are of the format `{day_of_week, day_name}`.

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