# Cldr Calendars

> My wife's jealousy is getting ridiculous. The other day she looked at my calendar and wanted to know who May was.
> -- Rodney Dangerfield

Calendars are curious things. For centuries people from all cultures have sought to impose human order on the astronomical movements of the earth and moon. Today, despite much of the world converting on the Gregorian calendar, there remain many derivative and alternative ways for humans to organize the passage of time.

`Cldr Calendars` builds on Elixir's standard `Calendar` module to provide additional calendars and calendar functionality intended to be of practical use.  In particular `Cdlr Calendars`:

* Provides support for configurable month-based and week-based calendars that are in common use as "Fiscal Year" calendars for countries and organizations around the world

* Supports localisation of common calendar terms such as "day of the week" and "month of the year" using the [CLDR](https://cldr.unicode.org) data that is available for over 500 locales

* Supports locale-specific knowledge of what is a weekend or a workday

## Getting Started

Let's say you work for [Cisco Systems](https://cisco.com). Your financial year is around knowing that the year ends on the last Saturday of July. To make things easy you'd like to compare the results of this financial year to last finanical year.  And you'd like to know how many days are left this quarter in order to achieve your sales targets.

Here's how we do that:

### Define a calendar that represents Cisco's financial year

Each calendar is defined as a module that implements both the `Calendar` and `Cldr.Calendar` behaviours.  The details of how that is achieved isn't important at this stage.  Its easy to define your own calendar module through some configuration parameters.  Here's how we do that for Cisco:
```
defmodule Cldr.Calendar.CSCO do
  use Cldr.Calendar.Base.Week,
    first_or_last: :last,
    day: 6,
    month: 7
end
```
This configuration says that the calendar is defined as `first_or_last: :last` which means we are defining a calendar in terms of when it ends (you can of course also define a calendar in terms of when it starts by setting this to `:first`).

The `:last` day is Saturday, which is in `Calendar` speak, the sixth day of the week.  Days of the week are numbered from `1` for Monday to `7` to Sunday.

The `:month` is July.  Months are numbered from January being `1` to December being `12`.

There we have it, a calendar that is based upon the definition of "ends of the last Saturday or July".

### Dates in Cisco's calendar

You might be wondering, how to we represent dates in a customised calendar like this? Thanks to the flexibility of Elixir's standard `Calendar` module, we can leverage existing functions to build a date.  Lets build a date which is the first day of Cisco's financial year for 2019.
```
{:ok, date} = Date.new(2019, 1, 1, Cldr.Calendar.CSCO)
{:ok, %Date{calendar: Cldr.Calendar.CSCO, day: 1, month: 1, year: 2019}}
```
That was easy.  All dates are specified *in the context of the specific calendar*.  We don't need to know what the equivalent Gregorian calendar date is.  But we can find out if we want to:
```
iex> Date.convert date, Calendar.ISO
{:ok, ~D[2018-07-29]}
```
Which you will see is July 29th, 2018 - a Sunday.  Since we specified that the `:last` day of the year is a Saturday this makes sense.  You will also note that this is a date in 2018 as it should be. The year ends in July so it must start around 12 months earlier - in July of 2018.

This would also mean that the last day of Fiscal Year 2018 must be July 28th, 2018.  Lets check:
```
iex> Cldr.Calendar.last_gregorian_day_of_year(2018, Cldr.Calendar.CSCO)
{:ok, %Date{calendar: Cldr.Calendar.Gregorian, day: 28, month: 7, year: 2018}}
```
Which you will see if the last Saturday in July for 2018.

### Years, quarters, months, weeks and days

A common activity with calendars is selecting data in certain date ranges or iterating over those same ranges. `Cldr Calendars` makes that easy.

Want to know what is the first quarter of Cisco's financial year in 2019?
```
 iex> range = Cldr.Calendar.quarter 2019, 1, Cldr.Calendar.CSCO
 #DateRange<%Date{calendar: Cldr.Calendar.CSCO, day: 1, month: 1, year: 2019}, %Date{calendar: Cldr.Calendar.CSCO, day: 7, month: 13, year: 2019}>
```
A `Date.Range.t` is returned which can be enumerated with any of Elixir's [Enum](https://hexdocs.pm/elixir/Enum.html) or [Stream](https://hexdocs.pm/elixir/Stream.html) functions. The same applies for `year`, `month`, `week` and `day`.

Let's list all of the days Cisco's first quarter:
```
iex> Enum.map range, &Cldr.Calendar.date_to_string/1
["2019-W01-1", "2019-W01-2", "2019-W01-3", "2019-W01-4", "2019-W01-5",
 "2019-W01-6", "2019-W01-7", "2019-W02-1", "2019-W02-2", "2019-W02-3",
 "2019-W02-4", "2019-W02-5", "2019-W02-6", "2019-W02-7", "2019-W03-1",
 "2019-W03-2", "2019-W03-3", "2019-W03-4", "2019-W03-5", "2019-W03-6",
 "2019-W03-7", "2019-W04-1", "2019-W04-2", "2019-W04-3", "2019-W04-4",
 "2019-W04-5", "2019-W04-6", "2019-W04-7", "2019-W05-1", "2019-W05-2",
 "2019-W05-3", "2019-W05-4", "2019-W05-5", "2019-W05-6", "2019-W05-7",
 "2019-W06-1", "2019-W06-2", "2019-W06-3", "2019-W06-4", "2019-W06-5",
 "2019-W06-6", "2019-W06-7", "2019-W07-1", "2019-W07-2", "2019-W07-3",
 "2019-W07-4", "2019-W07-5", "2019-W07-6", "2019-W07-7", "2019-W08-1", ...]
```
But wait a minute, these don't look like familiar dates!  Shouldn't they be formatted as "yyy-mm-dd"? The answer in this case is "no".

If you look carefully at where we asked for the date range for Cisco's first quarter of 2019 you will see `%Date{calendar: Cldr.Calendar.CSCO, day: 7, month: 13, year: 2019}` as the last date in the range. There is, of course, no such month as `13` in the Gregorian calendar.  What's going on?

## Week-based calendars

Cisco's calendar is an example of a "week-based" calendar. Such week-based calendars are examples of [fiscal year calendars](https://en.wikipedia.org/wiki/Fiscal_year). In `Cldr Calendar`, any calendar that is defined in terms of "[first | last] [day] of [month]" is a week-based calendar.  These calendars have a year of 52 weeks duration except in "leap years" that have 53 weeks.

The most well-known week-based calendar may be the [ISO Week Calendar](https://en.wikipedia.org/wiki/ISO_week_date). How would we define that calendar in `Cldr Calendars`? Easy!
```
defmodule Cldr.Calendar.ISOWeek do
  use Cldr.Calendar.Base.Week,
    day: 1,
    min_days: 4
end
```
This says that the calendar starts on the first Monday in January. How do we know that?  It's because
`:month` defaults to `1` (January) and `:first_or_last` defaults to `:first`.

Lets see what the first day of 2019 is in the `ISOWeek` calendar.
```
iex> date = Cldr.Calendar.first_day_of_year(2019, Cldr.Calendar.ISOWeek)
%Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 1, year: 2019}
```
As expected, the date is expressed in terms of the calendar `Cldr.Calendar.ISOWeek`. What's the equivalent Gregorian day?
```
iex> Date.convert(date, Calendar.ISO)
{:ok, ~D[2018-12-31]}
```
That's interesting.  The first day of the 2019 year in the ISO Week calendar is actually December 31st, 2018. Why is that?

Week-based calendars can start or end on a given day of the week in a given month.  But there is a third option: the given day of the week *nearest* to the start or end of the given month.  This is indicated by the configuration parameter `:min_days`.  For the `ISO Week` calendar we have `min_days: 4`.  That means that at least `4` days of the first or last week have to be in the specified `:month` and then we select the nearest day of the week.  Hence it is possible and even common for the gregorian start of the year for a week-based calendar to be up to 6 days before or after the Gregorian start of the year.

Whats the last week of 2019 in the `ISO Week` calendar?
```
 iex> date = Cldr.Calendar.week(2019, 52, Cldr.Calendar.ISOWeek)
 #DateRange<%Date{calendar: Cldr.Calendar.ISOWeek, day: 1, month: 52, year: 2019}, %Date{calendar: Cldr.Calendar.ISOWeek, day: 7, month: 52, year: 2019}>
```
You'll see that for week-based calendars the date is actually stored as `year, week, day` where the `:month` field of the `Date.t` is actually the week in the year and `:day` is the day in the week.


## Month-based calendars

## Beginning and ending gregorian years

When we talk about the Gregorian calendar we refer to the 12 months from January to December. However when we consider the various fiscal calendars, the Gregorian starting date and the Gregorian ending date will often be in different years.

In these cases, when we say "the 2019 US Fiscal Year" what does that mean?  The US fiscal year starts in October. Now we need to know whether refering to the "the 2019 US Fiscal Year" means the year that ends in September 2019 or the year that starts in October 2019.

Some further examples are:

* The UK Fiscal Year starts in April. By convention, the Fiscal Year is the year that starts with April.

* The US Fiscal Year starts in October.  By convention , the Fiscal Year is the year that has the ending October in it.

* The Australian Fiscal Year starts in July. By convention, the Fiscal Year is the year that ends in July.

* The National Retail Federation has a calendar that starts on the Saturday nearest the end of January.  By convention, the Fiscal Year is the year of the starting Saturday.

To cater for these varying definitions of what a Fiscal Year means, a configuration option `:year` can be set to `:majority` (which is the default), `:beginning` and `:ending`.

* `:majority` means that the Fiscal Year is the year that has the most Gregorian months in it. This is the default.
* `:beginning` means that the Fiscal Year is the year in which the first Gregorian month is found.
* `:ending` means that the Fiscal Year is the year in which the last Gregorian month is found.

First lets consider the default `:majority` strategy.  This strategy says that the Fiscal Year is that year in which the majority of Gregorian months are found.

                            2018                      2019                      2020
                  J F M A M J J A S O N D | J F M A M J J A S O N D | J F M A M J J A S O N D |
                  . . . . . . . . . . . . | . . . . . . . . . . . . | . . . . . . . . . . . . |
    Majority
      Starts Jan                            <--------------------->
      Starts Mar                                <----------------------->
      Starts Jun                                      <----------------------->
      Starts Jul              <----------------------->
      Starts Oct                    <----------------------->

      Ends Dec                              <--------------------->
      Ends Feb                                  <----------------------->
      Ends May                                        <----------------------->
      Ends Jun                <----------------------->
      Ends Aug                    <----------------------->



## Installation

Add `ex_cldr_calendars` to your `deps` in `mix.exs`:

```elixir
def deps do
  [
    {:ex_cldr_calendars, "~> 0.1.0"}
    ...
  ]
end
```

### To Do

* [ ] Implement hybrid base calendar. This is a week-based calendar that presents dates in a monthly format.  Symmetry454 is an example.

* [ ] Add module docs, especially configuration

* [ ] Add guides