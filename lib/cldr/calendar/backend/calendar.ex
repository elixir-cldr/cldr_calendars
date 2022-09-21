defmodule Cldr.Calendar.Backend do
  @moduledoc false

  def define_calendar_module(config) do
    backend = config.backend

    quote location: :keep, bind_quoted: [config: Macro.escape(config), backend: backend] do
      defmodule Calendar do
        @moduledoc false
        if Cldr.Config.include_module_docs?(config.generate_docs) do
          @moduledoc """
          Data functions to retrieve localised calendar
          information.

          `Cldr` defines formats for several calendars, the names of which
          are returned by `Cldr.known_calendars/0`.

          Currently this implementation only supports the `:gregorian`,
          `:persian`, `:coptic` and `ethiopic` calendars.

          The `:gregorian` calendar aligns with the proleptic Gregorian calendar
          defined by Elixir, `Calendar.ISO`.

          """
        end

        alias Cldr.Locale
        alias Cldr.Calendar
        alias Cldr.LanguageTag

        @default_calendar :gregorian
        @acceptable_calendars [
          :gregorian,
          :persian,
          :coptic,
          :ethiopic,
          :chinese,
          :japanese,
          :dangi
        ]

        @doc """
        Returns the calendar module preferred for
        a territory.

        ## Arguments

        * `territory` is any valid ISO3166-2 code as
          an `String.t` or upcased `atom()`

        ## Returns

        * `{:ok, calendar_module}` or

        * `{:error, {exception, reason}}`

        ## Examples

            iex> #{inspect __MODULE__}.calendar_from_territory :US
            {:ok, Cldr.Calendar.Gregorian}

            iex> #{inspect __MODULE__}.calendar_from_territory :XX
            {:error, {Cldr.UnknownTerritoryError, "The territory :XX is unknown"}}

        ## Notes

        The overwhelming majority of territories have
        `:gregorian` as their first preferred calendar
        and therefore `Cldr.Calendar.Gregorian`
        will be returned for most territories.

        Returning any other calendar module would require:

        1. That another calendar is preferred over `:gregorian`
           for a territory

        2. That a calendar module is available to support
           that calendar.

        As an example, Iran (territory `:IR`) prefers the
        `:persian` calendar. If the optional library
        [ex_cldr_calendars_persian](https://hex.pm/packages/ex_cldr_calendars_persian)
        is installed, the calendar module `Cldr.Calendar.Persian` will
        be returned. If it is not installed, `Cldr.Calendar.Gregorian`
        will be returned as `:gregorian` is the second preference
        for `:IR`.

        """
        def calendar_from_territory(territory) do
          Cldr.Calendar.calendar_from_territory(territory)
        end

        @doc """
        Return the calendar module for a locale.

        ## Arguments

        * `:locale` is any locale or locale name validated
          by `Cldr.validate_locale/2`.  The default is
          `Cldr.get_locale()` which returns the locale
          set for the current process

        ## Returns

        * `{:ok, calendar_module}` or

        * `{:error, {exception, reason}}`

        ## Examples

            iex> #{inspect __MODULE__}.calendar_from_locale "en-GB"
            {:ok, Cldr.Calendar.GB}

            iex> #{inspect __MODULE__}.calendar_from_locale "en-GB-u-ca-gregory"
            {:ok, Cldr.Calendar.Gregorian}

            iex> #{inspect __MODULE__}.calendar_from_locale "en"
            {:ok, Cldr.Calendar.US}

            iex> #{inspect __MODULE__}.calendar_from_locale "fa-IR"
            {:ok, Cldr.Calendar.Persian}

        """
        def calendar_from_locale(%LanguageTag{} = locale) do
          Cldr.Calendar.calendar_from_locale(locale)
        end

        def calendar_from_locale(locale) when is_binary(locale) do
          Cldr.Calendar.calendar_from_locale(locale, unquote(backend))
        end

        @doc """
        Returns a keyword list of options than can be applied to
        `NimbleStrftime.format/3`.

        The hex package [nimble_strftime](https://hex.pm/packages/nimble_strftime)
        provides a `format/3` function to format dates, times and datetimes.
        It takes a set of options that can return day, month and am/pm names.

        `strftime_options!` returns a keyword list than can be used as these
        options to return localised names for days, months and am/pm.

        ## Arguments

        * `locale` is any locale returned by `MyApp.Cldr.known_locale_names/0`. The
          default is `MyApp.Cldr.get_locale/0`

        * `options` is a set of keyword options. The default is `[]`

        ## Options

        * `:calendar` is the name of any known CLDR calendar. The default
          is `:gregorian`.

        ## Example

            iex: MyApp.Cldr.Calendar.strftime_options!
            [
              am_pm_names: #Function<0.32021692/1 in MyApp.Cldr.Calendar.strftime_options/2>,
              month_names: #Function<1.32021692/1 in MyApp.Cldr.Calendar.strftime_options/2>,
              abbreviated_month_names: #Function<2.32021692/1 in MyApp.Cldr.Calendar.strftime_options/2>,
              day_of_week_names: #Function<3.32021692/1 in MyApp.Cldr.Calendar.strftime_options/2>,
              abbreviated_day_of_week_names: #Function<4.32021692/1 in MyApp.Cldr.Calendar.strftime_options/2>
            ]

        ## Typical usage

            iex: NimbleStrftime.format(Date.today(), MyApp.Cldr.Calendar.strftime_options!())

        """

        def strftime_options!(locale \\ unquote(backend).get_locale(), options \\ []) do
          calendar = Keyword.get(options, :calendar, @default_calendar)

          with {:ok, locale} <- Cldr.validate_locale(locale) do
            [
              am_pm_names: fn am_pm ->
                day_periods(locale, calendar)
                |> get_in([:format, :abbreviated, am_pm])
              end,
              month_names: fn month ->
                months(locale, calendar)
                |> get_in([:format, :wide, month])
              end,
              abbreviated_month_names: fn month ->
                months(locale, calendar)
                |> get_in([:format, :abbreviated, month])
              end,
              day_of_week_names: fn day ->
                days(locale, calendar)
                |> get_in([:format, :wide, day])
              end,
              abbreviated_day_of_week_names: fn day ->
                days(locale, calendar)
                |> get_in([:format, :abbreviated, day])
              end
            ]
          else
            {:error, {exception, message}} -> raise exception, message
          end
        end

        def eras(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def eras(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          eras(cldr_locale_name, calendar)
        end

        def eras(locale_name, calendar) when is_binary(locale_name) do
          with {:ok, locale} <- unquote(backend).validate_locale(locale_name) do
            eras(locale, calendar)
          end
        end

        def quarters(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def quarters(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          quarters(cldr_locale_name, calendar)
        end

        def quarters(locale_name, calendar) when is_binary(locale_name) do
          with {:ok, locale} <- unquote(backend).validate_locale(locale_name) do
            quarters(locale, calendar)
          end
        end

        def months(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def months(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          months(cldr_locale_name, calendar)
        end

        def months(locale_name, calendar) when is_binary(locale_name) do
          with {:ok, locale} <- unquote(backend).validate_locale(locale_name) do
            months(locale, calendar)
          end
        end

        def days(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def days(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          days(cldr_locale_name, calendar)
        end

        def days(locale_name, calendar) when is_binary(locale_name) do
          with {:ok, locale} <- unquote(backend).validate_locale(locale_name) do
            days(locale, calendar)
          end
        end

        def day_periods(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def day_periods(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          day_periods(cldr_locale_name, calendar)
        end

        def day_periods(locale_name, calendar) when is_binary(locale_name) do
          with {:ok, locale} <- unquote(backend).validate_locale(locale_name) do
            day_periods(locale, calendar)
          end
        end

        def cyclic_years(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def cyclic_years(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          cyclic_years(cldr_locale_name, calendar)
        end

        def cyclic_years(locale_name, calendar) when is_binary(locale_name) do
          with {:ok, locale} <- unquote(backend).validate_locale(locale_name) do
            cyclic_years(locale, calendar)
          end
        end

        def month_patterns(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def month_patterns(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          month_patterns(cldr_locale_name, calendar)
        end

        def month_patterns(locale_name, calendar) when is_binary(locale_name) do
          with {:ok, locale} <- unquote(backend).validate_locale(locale_name) do
            month_patterns(locale, calendar)
          end
        end

        for locale_name <- Cldr.Locale.Loader.known_locale_names(config) do
          date_data =
            locale_name
            |> Cldr.Locale.Loader.get_locale(config)
            |> Map.get(:dates)

          # Should be Cldr.known_calendars() but
          # for now just calendars where we have
          # implementations.

          calendars =
            date_data
            |> Map.get(:calendars)
            |> Map.take(@acceptable_calendars)
            |> Map.keys()

          for calendar <- calendars do
            def eras(unquote(locale_name), unquote(calendar)) do
              unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :eras])))
            end

            def quarters(unquote(locale_name), unquote(calendar)) do
              unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :quarters])))
            end

            def months(unquote(locale_name), unquote(calendar)) do
              unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :months])))
            end

            def days(unquote(locale_name), unquote(calendar)) do
              unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :days])))
            end

            def day_periods(unquote(locale_name), unquote(calendar)) do
              unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :day_periods])))
            end

            def cyclic_years(unquote(locale_name), unquote(calendar)) do
              unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :cyclic_name_sets])))
            end

            def month_patterns(unquote(locale_name), unquote(calendar)) do
              unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :month_patterns])))
            end
          end

          def eras(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}

          def quarters(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}

          def months(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}

          def days(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}

          def day_periods(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}

          def cyclic_years(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}

          def month_patterns(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}
        end

        def eras(locale, _calendar), do: {:error, Locale.locale_error(locale)}
        def quarters(locale, _calendar), do: {:error, Locale.locale_error(locale)}
        def months(locale, _calendar), do: {:error, Locale.locale_error(locale)}
        def days(locale, _calendar), do: {:error, Locale.locale_error(locale)}
        def day_periods(locale, _calendar), do: {:error, Locale.locale_error(locale)}
        def cyclic_years(locale, _calendar), do: {:error, Locale.locale_error(locale)}
        def month_patterns(locale, _calendar), do: {:error, Locale.locale_error(locale)}
      end
    end
  end
end
