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

          Currently this implementation only supports the `:gregorian`
          calendar which aligns with the proleptic Gregorian calendar
          defined by Elixir, `Calendar.ISO`.

          """
        end

        alias Cldr.Locale
        alias Cldr.Calendar
        alias Cldr.LanguageTag

        @default_calendar :gregorian

        def eras(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def eras(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          eras(cldr_locale_name, calendar)
        end

        def quarters(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def quarters(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          quarters(cldr_locale_name, calendar)
        end

        def months(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def months(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          months(cldr_locale_name, calendar)
        end

        def days(locale \\ unquote(backend).get_locale(), calendar \\ @default_calendar)

        def days(%LanguageTag{cldr_locale_name: cldr_locale_name}, calendar) do
          days(cldr_locale_name, calendar)
        end

        for locale_name <- Cldr.Config.known_locale_names(config) do
          date_data =
            locale_name
            |> Cldr.Config.get_locale(config)
            |> Map.get(:dates)

          # Should be Cldr.known_calendars() but
          # for now just :gregorian
          calendars =
            date_data
            |> Map.get(:calendars)
            |> Map.take([@default_calendar])
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
          end

          def eras(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}

          def quarters(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}

          def months(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}

          def days(unquote(locale_name), calendar),
            do: {:error, Calendar.calendar_error(calendar)}
        end

        def eras(locale, _calendar), do: {:error, Locale.locale_error(locale)}
        def quarters(locale, _calendar), do: {:error, Locale.locale_error(locale)}
        def months(locale, _calendar), do: {:error, Locale.locale_error(locale)}
        def days(locale, _calendar), do: {:error, Locale.locale_error(locale)}
      end
    end
  end
end
