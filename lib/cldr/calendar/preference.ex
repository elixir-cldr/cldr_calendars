defmodule Cldr.Calendar.Preference do

  @territory_preferences Cldr.Config.calendar_preferences()
  def territory_preferences do
    @territory_preferences
  end

  def for_territory(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      territory_preferences = territory_preferences()
      default_territory = Cldr.default_territory()
      the_world = Cldr.the_world()

      preferences =
        Map.get(territory_preferences, territory) ||
        Map.get(territory_preferences, default_territory) ||
        Map.get(territory_preferences, the_world)

      {:ok, preferences}
    end
  end

  @doc """
  Returns the calendar module preferred for
  a territory.

  This function finds the first available calendar
  module that implements a preferred calendar and
  returns it.

  ## Arguments

  * `territory` is any valid ISO3166-2 code as
    a `String.t` or `atom()`

  ## Returns

  * `{:ok, calendar_module}` or

  * `{:error, {exception, reason}}`

  ## Examples

      iex> Cldr.Calendar.Preference.calendar_for_territory :US
      {:ok, Cldr.Calendar.Gregorian}

      iex> Cldr.Calendar.Preference.calendar_for_territory :XX
      {:error, {Cldr.UnknownTerritoryError, "The territory :XX is unknown"}}

  ## Notes

  The overwhelming number of territories have
  `:gregorian` as their first configured
  preferred calendar and therefore `Cldr.Calendar.Gregorian`
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
  def calendar_for_territory(territory) do
    with {:ok, preferences} <- for_territory(territory) do
      error = {:error, Cldr.unknown_calendar_error(preferences)}
      Enum.reduce_while(preferences, error, fn calendar, acc ->
        module = calendar_module(calendar)
        if Code.ensure_loaded?(module) do
          {:halt, {:ok, module}}
        else
          {:cont, acc}
        end
      end)
    end
  end

  @base_calendar Cldr.Calendar
  @known_calendars Cldr.known_calendars()

  @calendar_modules @known_calendars
  |> Enum.map(fn c ->
    {c, Module.concat(@base_calendar, c |> Atom.to_string |> Macro.camelize)}
  end)
  |> Map.new

  def calendar_modules do
    @calendar_modules
  end

  def calendar_module(calendar) when calendar in @known_calendars do
    Map.fetch!(calendar_modules(), calendar)
  end

  def calendar_module(other) do
    {:error, Cldr.unknown_calendar_error(other)}
  end
end