# Changelog for Cldr Calendars v0.2.0

This is the changelog for Cldr v0.2.0 released on April 14th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Breaking Changes

* All calendars now return `{year, month, day}` tuples from `date_from_iso_days/1`. Previously in some cases they returned a `Date.t`

* `first_day_of_year/1` and `last_day_of_year/1`, `first_gregorian_day_of_year/1` and `last_gregorian_day_of_year/1` now all return a `Date.t` or an error tuple.  Previously the returned result types were inconsistent.

### Enhancements

* Adds `Cldr.Calendar.Julian` implementing the Julian calendar. This implmentation does not implement `week/2`, `week_of_year/3` or `iso_week_of_year/3`.

### Bug Fixes

* Fixes calculating negative offsets for months in a week-based calendar.  Thanks to @bglusman. Closes #2.

# Changelog for Cldr Calendars v0.1.1

This is the changelog for Cldr v0.1.1 released on April 6th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Enhancements

* Remove `first_gregorian_day_of_year/1` and `last_gregorian_day_of_year/1` from `Cldr.Calendar` callbacks.

# Changelog for Cldr Calendars v0.1.0

This is the changelog for Cldr v0.1.0 released on April 5th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr_calendars/tags)

### Enhancements

* Initial release.  See the README for a description of this project.