defmodule Cldr.Calendar.Config do
  defstruct backend: nil,

            # The name of this calendar
            calendar: nil,

            # Locale can be used to derive
            # the :first_day and :min_days
            locale: nil,

            # Each quarter has three
            # 'months` each of 13 weeks
            # in either of a 4,4,5; 4,5,4
            # of 5,4,4 layout
            weeks_in_month: {4, 4, 5},

            # Calendar begins on the
            # :first, :last or :nearest
            anchor: :first,

            # Year begins on this day
            day: 1,

            # Year begins in this month
            month: 1,

            # The year of the last_day or first_day
            # is either the year with the :majority
            # of months or the :beginning year
            # or :ending year
            year: :majority,

            # First week has at least
            # this many days in current
            # year
            min_days: 4
end
